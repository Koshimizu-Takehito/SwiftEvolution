import Markdown
import MarkdownUI
import Splash
import SwiftData
import SwiftUI

import struct Markdown.Heading
import struct Markdown.Link

// MARK: - DetailView
struct ProposalDetailView: View {
    /// NavigationPath
    @Binding var path: NavigationPath
    /// 当該コンテンツ
    @State var markdown: Markdown

    /// SizeClass
    @Environment(\.verticalSizeClass) private var vertical
    /// ModelContext
    @Environment(\.modelContext) private var context
    /// ColorScheme
    @Environment(\.colorScheme) private var colorScheme
    /// 表示コンテンツで利用するシンタックスハイライト
    @AppStorage<SyntaxHighlight> private var highlight = .xcodeDark
    /// 該当コンテンツのブックマーク有無
    @State private var isBookmarked: Bool = false
    /// コンテンツロード済み
    @State private var isLoaded: Bool = false
    /// コンテンツ取得失敗
    @State private var error: Error?
    /// マークダウン取得エラー
    @State private var fetcherror: Error?
    /// マークダウン再取得トリガー
    @State private var refresh: UUID?

    @Environment(\.openURL) private var openURL

    @ViewBuilder
    var markdownView: some View {
        let markdownString = markdown.text ?? ""
        let document = Document(parsing: markdownString)
        var idCount = [String: Int]()
        let contents = Array(document.children.enumerated()).map { offset, content -> (markup: any Markup, id: String) in
            if let heading = content as? Heading {
                let heading = heading.format()
                let id = htmlID(fromMarkdownHeader: heading)
                let count = idCount[id]
                let _ = {
                    idCount[id] = (count ?? 0) + 1
                }()
                return (content, count.map { "\(id)-\($0)" } ?? id)
            } else {
                return (content, "\(offset)")
            }
        }
        ForEach(contents, id: \.id) { markup, id in
            MarkdownUI.Markdown(markup.format())
        }
        .markdownBulletedListMarker(.customCircle)
        .markdownNumberedListMarker(.customDecimal)
        .markdownTextStyle(\.code) {
            FontFamilyVariant(.monospaced)
            FontSize(.em(0.85))
            ForegroundColor(Color(UIColor.label))
            BackgroundColor(Color(UIColor.label).opacity(0.2))
        }
        .markdownBlockStyle(\.blockquote) { configuration in
            configuration.label
                .padding()
                .markdownTextStyle {
                    FontCapsVariant(.lowercaseSmallCaps)
                    FontWeight(.semibold)
                    BackgroundColor(nil)
                }
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(Color(UIColor.tintColor))
                        .frame(width: 4)
                }
                .background(Color(UIColor.tintColor).opacity(0.5))
        }
        .markdownBlockStyle(\.codeBlock) {
            MyCodeBlock(configuration: $0)
        }
        .markdownCodeSyntaxHighlighter(.splash(theme: theme))
        .opacity(markdownString.isEmpty ? 0 : 1)
        .animation(!translating ? .default : nil, value: markdownString)
    }

    private var theme: Splash.Theme {
        // NOTE: We are ignoring the Splash theme font
        switch colorScheme {
        case .dark:
            return .wwdc18(withFont: .init(size: 16))
        default:
            return .sunset(withFont: .init(size: 16))
        }
    }

    func openURL(_ url: URL, with proxy: ScrollViewProxy) -> OpenURLAction.Result {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return .systemAction
        }
        switch (components.scheme, components.host, components.path) {
        case (_, "github.com", let path):
            guard let match = path.firstMatch(of: /^.+\/swift-evolution\/.*\/(\d+)-.*\.md/) else {
                break
            }
            // 別プロポーザルへのリンクを送信
            showProposal(id: match.1, url: url)
            return .discarded
        case (nil, nil, "") where components.fragment?.isEmpty == false:
            // ページ内のアンカー
            withAnimation {
                proxy.scrollTo(url.absoluteString, anchor: .top)
            }
            return .discarded
        case (nil, nil, let path):
            guard let match = path.firstMatch(of: /(\d+)-.*\.md$/) else {
                break
            }
            // 別プロポーザルへのリンクを送信
            showProposal(id: match.1)
            return .discarded
        default:
            return .discarded
        }
        return .discarded
    }

    var body: some View {
        ScrollViewReader { proxy in
            List {
                markdownView.environment(\.openURL, OpenURLAction {
                    openURL($0, with: proxy)
                })
                .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 12, trailing: 6))
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, 1)
        }
        .toolbar {
            // ツールバー
            toolbar
        }
        .onAppear {
            // ブックマークの状態を復元
            let object = ProposalObject[markdown.proposal.id, in: context]
            isBookmarked = object?.isBookmarked == true
        }
        .onChange(of: isBookmarked) { _, new in
            saveBookmark(isBookmarked: new)
        }
        .overlay {
            // エラー画面
            ErrorView(error: fetcherror) {
                refresh = .init()
            }
        }
        .navigationTitle(markdown.proposal.title)
        .iOSNavigationBarTitleDisplayMode(.inline)
        .tint(markdown.proposal.state?.color)
        .task(id: refresh) {
            // マークダウンテキストを取得
            await fetchMarkdownText()
        }
    }

    func fetchMarkdownText() async {
        fetcherror = nil
        do {
            markdown.text = try await markdown.fetch()
        } catch let error as URLError {
            if error.code != URLError.cancelled {
                fetcherror = error
            }
        } catch {
            fetcherror = error
        }
    }

    @State var translating = false

    /// ツールバー
    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        ToolbarItem {
            BookmarkButton(isBookmarked: $isBookmarked)
        }
        ToolbarSpacer()
        ToolbarItemGroup {
            #if os(iOS) || os(iPadOS)
                if !translating {
                    Button("翻訳", systemImage: "character.bubble") {
                        Task {
                            if let text = markdown.text {
                                translating = true; defer { translating = false }
                                let translator = MarkdownTranslator()
                                for try await result in await translator.translate(markdown: text) {
                                    guard markdown.text != result else {
                                        continue
                                    }
                                    markdown.text = result
                                    await Task.yield()
                                }
                            }
                        }
                        Task {
                            if let text = markdown.text {
                                var reader = LinkReader()
                                reader.visit(Document(parsing: text))
                            }
                        }
                    }
                } else {
                    ZStack {
                        Button("翻訳", systemImage: "character.bubble") {}
                            .hidden()
                        ProgressView()
                    }
                }
                Menu("Settings", systemImage: "gearshape") {
                    Picker("Settings", systemImage: "gearshape", selection: $highlight) {
                        ForEach(SyntaxHighlight.allCases) { item in
                            Text(item.displayName)
                                .tag(item)
                        }
                    }
                }
            #else
                Picker(selection: $highlight) {
                    ForEach(SyntaxHighlight.allCases) { item in
                        Text(item.displayName)
                            .tag(item)
                    }
                } label: {
                    Image(systemName: "gearshape")
                }
            #endif
        }
    }
}

extension ProposalDetailView {
    /// 当該プロポーザルのブックマークの有無を保存
    fileprivate func saveBookmark(isBookmarked: Bool) {
        let proposal = ProposalObject[markdown.proposal.id, in: context]
        guard let proposal else { return }
        proposal.isBookmarked = isBookmarked
        try? proposal.modelContext?.save()
    }

    /// 指定したプロポーザルを表示する
    fileprivate func showProposal(id: some StringProtocol, url: URL? = nil) {
        let id = "SE-\(String(id))"
        let url = url.map(MarkdownURL.init(rawValue:))
        let context = context.container.mainContext
        guard let proposal = ProposalObject[id, in: context] else {
            return
        }
        path.append(Markdown(proposal: .init(proposal), url: url))
    }
}

/// Markdownのヘッダー行からHTMLのidスラッグを作る
/// - Parameters:
///   - line: 例: "### `~Copyable` as logical negation"
///   - includeHash: 先頭に `#` を付ける（デフォルト true）
/// - Returns: 例: "#copyable-as-logical-negation"
func htmlID(fromMarkdownHeader line: String, includeHash: Bool = true) -> String {
    // 1) 先頭の見出しマーカーを除去（0〜3個の空白 + #1〜6 + 空白）
    let headerPattern = #"^\s{0,3}#{1,6}\s+"#
    let textStart = line.replacingOccurrences(of: headerPattern,
                                              with: "",
                                              options: .regularExpression)

    // 2) バッククォートとかっこを除去（中身は残す）
    var s = textStart.replacingOccurrences(of: "`", with: "")
        .replacingOccurrences(of: "(", with: "")
        .replacingOccurrences(of: ")", with: "")

    // 3) Unicode正規化（ローマ字化→ダイアクリティカル除去）
    //    例: "Café" -> "Cafe", 日本語は toLatin でローマ字化される場合あり
    if let latin = s.applyingTransform(.toLatin, reverse: false) {
        s = latin
    }
    s = s.folding(options: [.diacriticInsensitive, .caseInsensitive],
                  locale: .current)

    // 4) 小文字化
    s = s.lowercased()

    // 5) 許可しない文字をハイフンに置換（英数以外はまとめて-）
    //    連続する非英数字は1つのハイフンに圧縮
    s = s.replacingOccurrences(of: #"[^a-z0-9]+"#,
                               with: "-",
                               options: .regularExpression)

    // 6) 前後のハイフンをトリム
    s = s.trimmingCharacters(in: CharacterSet(charactersIn: "-"))

    // 7) 空ならフォールバック
    if s.isEmpty { s = "section" }

    return includeHash ? "#\(s)" : s
}

#if DEBUG
    #Preview {
        PreviewContainer {
            NavigationStack {
                ProposalDetailView(path: .fake, markdown: .fake0418)
            }
        }
    }
#endif
