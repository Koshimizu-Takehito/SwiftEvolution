import SwiftUI
import SwiftData

// MARK: - 
/// ContentView
struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontal
    /// ModelContext
    @Environment(\.modelContext) private var context
    /// ナビゲーションバーの現在の色合い
    @State private var tintColor: Color?
    /// ブックマークでのフィルタ有無
    @AppStorage("isBookmarked") private var isBookmarked: Bool = false
    /// リスト取得エラー
    @State private var fetcherror: Error?
    /// リスト再取得トリガー
    @State private var refresh: UUID?
    /// すべてのプロポーザル
    @Query(animation: .default) private var allProposals: [ProposalObject]
    /// 選択中のステータス
    @AppStorage var status: Set<ProposalStatus> = .allCases
    /// すべてのブックマーク
    @State private var allBookmark: [ProposalID] = []
    /// リスト画面で選択された詳細画面のコンテンツ
    @State private var selection: Markdown?

    var body: some View {
        NavigationSplitView {
            // リスト画面
            ProposalListView(
                horizontal: horizontal,
                selection: $selection,
                status: status,
                isBookmarked: !allBookmark.isEmpty && isBookmarked
            )
            .overlay {
                // エラー画面
                ErrorView(error: fetcherror) {
                    refresh = .init()
                }
            }
            .toolbar {
                // ツールバー
                toolbar
            }
        } detail: {
            // 詳細画面
            if let selection {
                ContentDetailView(
                    markdown: selection,
                    horizontal: horizontal,
                    accentColor: detailTint
                )
                .id(selection)
            }
        }
        .tint(barTint)
        .task(id: refresh) {
            await refresh()
        }
        .onChange(of: try! allProposals.filter(.bookmark), initial: true) { _, new in
            withAnimation { allBookmark = new.map(\.id) }
        }
    }

    /// ツールバー
    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        if !allBookmark.isEmpty {
            ToolbarItem {
                BookmarkButton(isBookmarked: $isBookmarked)
                    .disabled(allBookmark.isEmpty)
                    .opacity(allBookmark.isEmpty ? 0 : 1)
                    .onChange(of: allBookmark.isEmpty) { _, isEmpty in
                        if isEmpty {
                            isBookmarked = false
                        }
                    }
                    .tint(.darkText)
            }
        }
        ToolbarSpacer()
        if !allProposals.isEmpty {
            ToolbarItem {
                ProposalStatusPicker()
                    .tint(.darkText)
            }
        }
    }
}

private extension ContentView {
    @MainActor
    func refresh() async {
        fetcherror = nil
        do {
            try await ProposalObject.fetch(context: context)
        } catch {
            if allProposals.isEmpty {
                fetcherror = error
            }
        }
    }

    var detailTint: Binding<Color?> {
        switch horizontal {
        case .compact:
            return $tintColor
        default:
            return .constant(nil)
        }
    }

    var barTint: Color? {
        switch horizontal {
        case .compact:
            return tintColor ?? .darkText
        default:
            return .darkText
        }
    }
}

#if DEBUG
#Preview {
    PreviewContainer { context in
        ContentView()
    }
}
#endif
