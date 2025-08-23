import EvolutionCore
import EvolutionUI
import SwiftUI

// MARK: -
/// SplitView の Detail View
///
/// Detail View 側のナビゲーションスタックの管理を行う
struct ContentDetailView: View {
    /// 詳細画面のNavigationPath
    @State private var detailPath = NavigationPath()
    /// 表示する値
    let markdown: Markdown
    /// 水平サイズクラス
    let horizontal: UserInterfaceSizeClass?
    /// アクセントカラー（ ナビゲーションスタックにスタックされるごとに変更する ）
    @Binding var accentColor: Color?

    /// ModelContext
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack(path: $detailPath) {
            // Root
            detail(markdown: markdown)
        }
        .navigationDestination(for: Markdown.self) { markdown in
            // Destination
            detail(markdown: markdown)
        }
    }

    func detail(markdown: Markdown) -> some View {
        ProposalDetailView(path: $detailPath, markdown: markdown, context: context)
            .onChange(of: accentColor(markdown), initial: true) { _, color in
                accentColor = color
            }
    }

    func accentColor(_ markdown: Markdown) -> Color {
        markdown.proposal.state?.color ?? .darkText
    }
}

#Preview(traits: .proposal) {
    ContentDetailView(
        markdown: .fake0418,
        horizontal: .compact,
        accentColor: .constant(.green)
    )
}
