import Markdown
import MarkdownUI
import Splash
import SwiftData
import SwiftUI

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

    public static var myCircle: BlockStyle<ListMarkerConfiguration> {
        BlockStyle { _ in
            Circle()
                .frame(width: 6, height: 6)
                .relativeFrame(minWidth: .zero, alignment: .trailing)
        }
    }

    public static var myDecimal: BlockStyle<ListMarkerConfiguration> {
        BlockStyle { configuration in
            Text("\(configuration.itemNumber).")
                .monospacedDigit()
                .relativeFrame(minWidth: .zero, alignment: .trailing)
        }
    }

    @ViewBuilder
    var markdownView: some View {
        let markdownString = markdown.text ?? ""
        let document = Document(parsing: markdownString)
        let contents = document.children.map { $0.format() }
        LazyVStack(alignment: .leading, spacing: 12) {
            ForEach(Array(contents.enumerated()), id: \.offset) { offset, content in
                let hoge = Document(parsing: content).children.first { _ in true }
                let _ = print("🩵", (hoge?.format()).debugDescription)
                MarkdownUI.Markdown(content)
            }
        }
        .markdownBulletedListMarker(Self.myCircle)
        .markdownNumberedListMarker(Self.myDecimal)
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
            codeBlock($0)
        }
        .markdownCodeSyntaxHighlighter(.splash(theme: self.theme))
        .opacity(markdownString.isEmpty ? 0 : 1)
        .animation(!translating ? .default : nil, value: markdownString)
        .padding()
        .padding(.bottom)
    }

    @ViewBuilder
    private func codeBlock(_ configuration: CodeBlockConfiguration) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(configuration.language ?? "plain text")
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(theme.plainTextColor))
                Spacer()

                Image(systemName: "clipboard")
                    .onTapGesture {
                        copyToClipboard(configuration.content)
                    }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background {
                Color(theme.backgroundColor)
            }

            Divider()

            ScrollView(.horizontal) {
                configuration.label
                    .relativeLineSpacing(.em(0.25))
                    .markdownTextStyle {
                        FontFamilyVariant(.monospaced)
                        FontSize(.em(0.85))
                    }
                    .padding()
            }
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .markdownMargin(top: .zero, bottom: .em(0.8))
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

    private func copyToClipboard(_ string: String) {
        #if os(macOS)
            if let pasteboard = NSPasteboard.general {
                pasteboard.clearContents()
                pasteboard.setString(string, forType: .string)
            }
        #elseif os(iOS)
            UIPasteboard.general.string = string
        #endif
    }

    var body: some View {
        ScrollView {
            markdownView
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
        .ignoresSafeArea(edges: .bottom)
        .tint(markdown.proposal.state?.color)
        .task(id: refresh) {
            // マークダウンテキストを取得
            await fetchMarkdownText()
        }
        .environment(\.openURL, OpenURLAction { url in
            print("✅✅✅", url.description)
            return .discarded
        })
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
    fileprivate func showProposal(_ value: Markdown) {
        path.append(value)
    }
}

struct TextOutputFormat: Splash.OutputFormat {
    private let theme: Splash.Theme

    init(theme: Splash.Theme) {
        self.theme = theme
    }

    func makeBuilder() -> Builder {
        Builder(theme: theme)
    }
}

extension TextOutputFormat {
    struct Builder: OutputBuilder {
        private let theme: Splash.Theme
        private var string: AttributedString

        fileprivate init(theme: Splash.Theme) {
            self.theme = theme
            self.string = .init()
        }

        mutating func addToken(_ token: String, ofType type: TokenType) {
            var part = AttributedString(token)
            part.foregroundColor = theme.tokenColors[type] ?? theme.plainTextColor
            string += part
        }

        mutating func addPlainText(_ text: String) {
            var part = AttributedString(text)
            part.foregroundColor = theme.plainTextColor
            string += part
        }

        mutating func addWhitespace(_ whitespace: String) {
            string += AttributedString(whitespace)
        }

        func build() -> SwiftUI.Text {
            SwiftUI.Text(string)
        }
    }
}

struct SplashCodeSyntaxHighlighter: CodeSyntaxHighlighter {
    private let syntaxHighlighter: SyntaxHighlighter<TextOutputFormat>

    init(theme: Splash.Theme) {
        self.syntaxHighlighter = SyntaxHighlighter(format: TextOutputFormat(theme: theme))
    }

    func highlightCode(_ content: String, language: String?) -> SwiftUI.Text {
        guard language != nil else {
            return SwiftUI.Text(content)
        }
        return self.syntaxHighlighter.highlight(content)
    }
}

extension CodeSyntaxHighlighter where Self == SplashCodeSyntaxHighlighter {
    static func splash(theme: Splash.Theme) -> Self {
        SplashCodeSyntaxHighlighter(theme: theme)
    }
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
