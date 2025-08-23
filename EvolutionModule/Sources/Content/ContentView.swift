import EvolutionCore
import EvolutionModel
import EvolutionUI
import SwiftData
import SwiftUI

// MARK: - ContentView

/// ContentView
@MainActor
public struct ContentView {
    @Environment(\.horizontalSizeClass) private var horizontal
    /// ModelContext
    @Environment(\.modelContext) private var context
    /// ナビゲーションバーの現在の色合い
    @State private var tint: Color?
    /// ブックマークでのフィルタ有無
    @AppStorage("isBookmarked") private var isBookmarked = false
    /// リスト取得エラー
    @State private var fetcherror: Error?
    /// リスト再取得トリガー
    @State private var refresh: UUID?
    /// すべてのプロポーザル
    @Query private var allProposals: [ProposalObject]
    /// 選択中のステータス
    @AppStorage private var status: Set<ProposalStatus> = .allCases
    /// すべてのブックマーク
    @State private var bookmarks: [ProposalObject] = []
    /// リスト画面で選択された詳細画面のコンテンツ
    @State private var selection: Markdown?

    private var detailTint: Binding<Color?> {
        switch horizontal {
        case .compact:
            return $tint
        default:
            return .constant(nil)
        }
    }

    private var barTint: Color? {
        switch horizontal {
        case .compact:
            return tint ?? .darkText
        default:
            return .darkText
        }
    }

    public init() {}
}

// MARK: - View

extension ContentView: View {
    public var body: some View {
        NavigationSplitView {
            // リスト画面
            ProposalListView(
                selection: $selection,
                status: status,
                isBookmarked: !bookmarks.isEmpty && isBookmarked
            )
            .environment(\.horizontalSizeClass, horizontal)
            .overlay { ErrorView(error: fetcherror, $refresh) }
            .toolbar { toolbar }
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
            fetcherror = nil
            do {
                try await ProposalObject.fetch(container: context.container)
            } catch {
                if allProposals.isEmpty {
                    fetcherror = error
                }
            }
        }
        .animation(.default, value: bookmarks)
        .onChange(of: try! allProposals.filter(.bookmark), initial: true) {
            bookmarks = $1
        }
    }

    /// ツールバー
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        if !bookmarks.isEmpty {
            ToolbarItem {
                BookmarkButton(isBookmarked: $isBookmarked)
                    .disabled(bookmarks.isEmpty)
                    .opacity(bookmarks.isEmpty ? 0 : 1)
                    .onChange(of: bookmarks.isEmpty) { _, isEmpty in
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

#Preview(traits: .proposal) {
    ContentView()
        .environment(\.colorScheme, .dark)
}

#Preview("Assistive access", traits: .proposal, .assistiveAccess) {
    ContentView()
        .environment(\.colorScheme, .dark)
}
