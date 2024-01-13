import SwiftUI
import SwiftData

// MARK: - 
/// ContentView
struct ContentView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
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
    /// 選択中のステータス
    @Environment(PickedStatus.self) private var states
    /// 詳細画面のコンテンツURL
    @State private var detailURL: ProposalURL?

    var body: some View {
        NavigationSplitView {
            // リスト画面
            ProposalListView(
                horizontalSizeClass: horizontalSizeClass,
                detailURL: $detailURL,
                states: states.current,
                isBookmarked: isBookmarked
            )
            .tint(.darkText.opacity(0.2))
            .overlay {
                // エラー画面
                ErrorView(error: fetcherror, retry: retry)
            }
            .toolbar {
                if !allProposals.isEmpty {
                    // ツールバー
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        HStack {
                            Button(
                                action: {
                                    withAnimation {
                                        isBookmarked.toggle()
                                    }
                                },
                                label: {
                                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                    .imageScale(.large)
                                }
                            )
                            .animation(.default, value: isBookmarked)

                            ProposalStatusPicker()
                        }
                        .tint(.darkText)
                    }
                }
            }
        } detail: {
            // 詳細画面
            if let detailURL {
                SplitDetailView(url: detailURL, tintColor: detailTint)
                    .id(detailURL)
            }
        }
        .tint(listTint)
        .task(id: refresh) { await refresh() }
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
        switch horizontalSizeClass {
        case .compact:
            return $tintColor
        default:
            return .constant(nil)
        }
    }

    var listTint: Color? {
        switch horizontalSizeClass {
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
    /// ナビゲーションバーの現在の色合い
    @Binding var tintColor: Color?

    var body: some View {
        NavigationStack(path: $detailPath) {
            // 詳細画面
            ProposalDetailView(path: $detailPath, tint: $tintColor, url: url)
        }
        .navigationDestination(for: ProposalURL.self) { url in
            // 詳細画面内のリンクURLタップ時に、該当のURLで別途詳細画面を表示する
            ProposalDetailView(path: $detailPath, tint: $tintColor, url: url)
        }
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