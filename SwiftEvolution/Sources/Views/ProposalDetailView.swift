import SwiftUI
import SwiftData

// MARK: - DetailView
struct ProposalDetailView: View {
    /// SizeClass
    @Environment(\.verticalSizeClass) private var vertical
    /// ModelContext
    @Environment(\.modelContext) private var context
    /// 表示コンテンツで利用するシンタックスハイライト
    @AppStorage<SyntaxHighlight> private var highlight = .atomOneDark
    /// 該当コンテンツのブックマーク有無
    @State private var isBookmarked: Bool = false
    /// コンテンツロード済み
    @State private var isLoaded: Bool = false
    /// コンテンツ取得失敗
    @State private var error: Error?
    /// NavigationPath
    @Binding private var path: NavigationPath
    /// TintColor
    @Binding private var tint: Color?
    /// HTML を再生成するための識別子
    @State private var HTMLRebuildId = UUID()
    /// マークダウンから生成される HTML
    @State private var html: String?
    /// 当該コンテンツ
    @State private var markdown: Markdown

    init(
        path: Binding<NavigationPath>,
        tint: Binding<Color?> = .constant(nil),
        markdown: Markdown
    ) {
        self._path = path
        self._tint = tint
        self._markdown = .init(initialValue: markdown)
    }

    var body: some View {
        // WebView（ コンテンツの HTML を読み込む ）
        ProposalDetailWebView(
            html: html,
            isLoaded: $isLoaded.animation(),
            onTapLinkURL: showProposal
        )
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
        .onChange(of: statusColor, initial: true) {
            tint = statusColor
        }
        .opacity(isLoaded ? 1 : 0)
        .navigationTitle(markdown.proposal.title)
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .ignoresSafeArea(edges: .bottom)
        .tint(statusColor)
        .task(id: HTMLRebuildId) {
            // マークダウンファイルを HTML ファイルに変換
            html = try? await markdown.buildHTML(highlight: highlight)
        }
    }

    /// ツールバー
    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .detail(for: vertical)) {
            HStack {
                Spacer()
                BookmarkButton(isBookmarked: $isBookmarked)
                Menu {
                    ForEach(SyntaxHighlight.allCases) { item in
                        Button(item.displayName) {
                            highlight = item
                            HTMLRebuildId = .init()
                        }
                    }
                } label: {
                    Image(systemName: "gearshape")
                        .imageScale(.large)
                }
                .menuOrder(.fixed)
            }
            .opacity(isLoaded ? 1 : 0)
        }
    }
}

private extension ProposalDetailView {
    /// 当該プロポーザルのレビューステータスに関連した色
    var statusColor: Color? {
        markdown.proposal.state?.color
    }

    /// 当該プロポーザルのブックマークの有無を保存
    func saveBookmark(isBookmarked: Bool) {
        let proposal = ProposalObject[markdown.proposal.id, in: context]
        guard let proposal else { return }
        proposal.isBookmarked = isBookmarked
        try? proposal.modelContext?.save()
    }

    /// 指定したプロポーザルを表示する
    func showProposal(_ value: Markdown) {
        path.append(value)
    }
}

#if DEBUG
#Preview {
    PreviewContainer {
        NavigationStack {
            ProposalDetailView(path: .fake, tint: .fake, markdown: .fake0418)
        }
    }
}
#endif
