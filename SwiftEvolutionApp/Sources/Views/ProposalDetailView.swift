import SwiftUI
import SwiftData

extension ProposalDetailView {
    init(
        path: Binding<NavigationPath>,
        tint: Binding<Color?> = .constant(nil),
        url: ProposalURL
    ) {
        let markdown = Markdown(url: url)
        self.init(path: path, tint: tint, markdown: markdown)
    }
}

// MARK: - DetailView
struct ProposalDetailView: View {
    /// SizeClass
    @Environment(\.verticalSizeClass) private var vertical
    /// ModelContext
    @Environment(\.modelContext) private var context
    /// 該当コンテンツのブックマーク有無
    @State private var isBookmarked: Bool = false
    /// コンテンツロード済み
    @State private var isLoaded: Bool = false
    /// コンテンツ取得失敗
    @State private var error: Error?
    /// 再取得処理を発火するためのUUID
    @State private var refresh = UUID()
    /// NavigationPath
    @Binding private var path: NavigationPath
    /// TintColor
    @Binding private var tint: Color?
    /// 当該コンテンツ（Model）
    private let markdown: Markdown

    var body: some View {
        // WebView（ コンテンツの HTML を読み込む ）
        ProposalDetailWebView(
            html: markdown.html,
            highlight: markdown.highlight,
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
                            markdown.highlight = item
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
    func showProposal(_ url: ProposalURL) {
        path.append(url)
    }
}

#if DEBUG
#Preview {
    PreviewContainer {
        NavigationStack {
            ProposalDetailView(path: .fake, tint: .fake, url: .fake0418)
        }
    }
}
#endif
