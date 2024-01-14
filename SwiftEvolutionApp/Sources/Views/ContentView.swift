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
    @State private var isBookmarked: Bool = false
    /// リスト取得エラー
    @State private var fetcherror: Error?
    /// リスト再取得トリガー
    @State private var refresh = UUID()
    /// すべてのプロポーザル
    @Query(animation: .default) private var allProposals: [ProposalObject]
    /// すべてのブックマーク
    @State private var allBookmark: [ProposalID] = []
    /// 選択中のステータス
    @Environment(PickedStatus.self) private var status
    /// 詳細画面のコンテンツURL
    @State private var detailURL: ProposalURL?

    var body: some View {
        NavigationSplitView {
            // リスト画面
            ProposalListView(
                horizontal: horizontal,
                detailURL: $detailURL,
                status: status.current,
                isBookmarked: !allBookmark.isEmpty && isBookmarked
            )
            .overlay {
                // エラー画面
                ErrorView(error: fetcherror, retry: retry)
            }
            .toolbar {
                // ツールバー
                toolbar
            }
        } detail: {
            // 詳細画面
            if let detailURL {
                ContentDetailView(
                    url: detailURL,
                    horizontal: horizontal,
                    tintColor: detailTint
                )
                .id(detailURL)
            }
        }
        .tint(barTint)
        .task(id: refresh) { await refresh() }
        .onChange(of: try! allProposals.filter(.bookmark), initial: true) { _, new in
            withAnimation { allBookmark = new.map(\.id) }
        }
    }

    /// ツールバー
    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        if !allProposals.isEmpty {
            ToolbarItemGroup(placement: .topBarTrailing) {
                HStack {
                    BookmarkButton(isBookmarked: $isBookmarked)
                        .disabled(allBookmark.isEmpty)
                        .opacity(allBookmark.isEmpty ? 0 : 1)
                        .onChange(of: allBookmark.isEmpty) { _, isEmpty in
                            if isEmpty {
                                isBookmarked = false
                            }
                        }
                    ProposalStatusPicker()
                }
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

    func retry() {
        refresh = .init()
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

#Preview {
    PreviewContainer {
        ContentView()
    }
}
