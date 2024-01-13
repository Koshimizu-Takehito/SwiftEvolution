import SwiftUI
import SwiftData

// MARK: - 
/// ContentView
struct ContentView: View {
    @Environment(\.horizontalSizeClass) var horizontal
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
    @Query(animation: .default) 
    private var allProposals: [ProposalObject]
    /// すべてのブックマーク
    @Query(filter: .bookmark, animation: .default) 
    private var allBookmark: [ProposalObject]
    /// 選択中のステータス
    @Environment(PickedStatus.self) private var states
    /// 詳細画面のコンテンツURL
    @State private var detailURL: ProposalURL?

    var body: some View {
        NavigationSplitView {
            // リスト画面
            ProposalListView(
                horizontal: horizontal,
                detailURL: $detailURL,
                states: states.current,
                isBookmarked: !allBookmark.isEmpty && isBookmarked
            )
            .tint(.darkText.opacity(0.2))
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
                SplitDetailView(
                    url: detailURL,
                    horizontal: horizontal,
                    tintColor: detailTint
                )
                .id(detailURL)
            }
        }
        .tint(listTint)
        .task(id: refresh) { await refresh() }
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

    var listTint: Color? {
        switch horizontal {
        case .compact:
            return tintColor ?? .darkText
        default:
            return .darkText
        }
    }
}

// MARK: -
/// SplitViewの詳細
private struct SplitDetailView: View {
    /// 詳細画面のNavigationPath
    @State private var detailPath = NavigationPath()
    /// 詳細画面のコンテンツURL
    let url: ProposalURL
    /// 水平サイズクラス
    let horizontal: UserInterfaceSizeClass?
    /// ナビゲーションバーの現在の色合い
    @Binding var tintColor: Color?

    var body: some View {
        NavigationStack(path: $detailPath, root: rootView)
            .navigationDestination(
                for: ProposalURL.self,
                destination: destinationView(url:)
            )
    }

    func rootView() -> some View {
        Group {
            switch (horizontal, tintColor) {
            case (.compact, .none):
                // compact の場合は tint の設定まで描画を遅延
                EmptyView()
            case (_, _):
                ProposalDetailView(path: $detailPath, url: url)
            }
        }
        .onChange(of: initialTintColor, initial: true) { _, color in
            tintColor = color
        }
    }

    /// 詳細画面内のリンクURLタップ時に、該当のURLで別途詳細画面を表示する
    func destinationView(url: ProposalURL) -> some View {
        ProposalDetailView(path: $detailPath, tint: $tintColor, url: url)
    }

    var initialTintColor: Color {
        url.proposal.state?.color ?? .darkText
    }
}

extension Color {
    static var darkText: Color {
        Color(UIColor.label)
    }
}

#Preview {
    PreviewContainer {
        ContentView()
    }
}
