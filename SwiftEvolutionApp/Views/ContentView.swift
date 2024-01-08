import SwiftUI
import SwiftData

struct ContentView: View {
    /// NavigationPath
    @State private var path = NavigationPath()
    /// ModelContext
    @Environment(\.modelContext) private var context
    /// ナビゲーションバーの現在の色合い
    @State private var tintColor: Color?
    /// ブックマークでのフィルタ有無
    @State private var isFilteredBookmark: Bool = false
    /// リスト取得エラー
    @State private var listFetcherror: Error?
    /// リスト再取得トリガー
    @State private var listRefreshRrigger = UUID()
    /// すべてのプロポーザル
    @Query(animation: .default) private var allProposals: [ProposalObject]
    /// 選択中のステータス
    @Environment(PickedStates.self) private var states

    var body: some View {
        NavigationStack(path: $path) {
            // リスト画面
            ProposalListView(
                path: $path,
                states: states.current,
                isBookmarked: isFilteredBookmark
            )
            .animation(.default, value: states.current)
            .overlay {
                if let listFetcherror {
                    // エラー画面
                    ErrorView(error: listFetcherror, retry: retry)
                }
            }
            .navigationDestination(for: ProposalURL.self) { url in
                // 詳細画面
                ProposalDetailView(path: $path, tint: $tintColor, url: url)
            }
            .toolbar {
                if !allProposals.isEmpty {
                    // ツールバー
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Group {
                            Toggle(isOn: $isFilteredBookmark.animation()) {
                                Image(systemName: "bookmark")
                                    .imageScale(.large)
                            }
                            .toggleStyle(.button)

                            ProposalStatePicker()
                        }
                        .tint(Color(UIColor.label))
                    }
                }
            }
        }
        .tint(tintColor)
        .task(id: listRefreshRrigger) { await refresh() }
    }
}

private extension ContentView {
    @MainActor
    func refresh() async {
        withAnimation { self.listFetcherror = nil }
        do {
            try await ProposalObject.fetch(context: context)
        } catch {
            if allProposals.isEmpty {
                withAnimation { self.listFetcherror = error }
            }
        }
    }

    func retry() {
        listRefreshRrigger = .init()
    }
}

#Preview {
    PreviewContainer {
        ContentView()
    }
}
