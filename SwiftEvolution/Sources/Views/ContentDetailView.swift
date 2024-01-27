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
    /// ナビゲーションバーの現在の色合い
    @Binding var tintColor: Color?

    var body: some View {
        NavigationStack(path: $detailPath, root: root)
            .navigationDestination(
                for: Markdown.self,
                destination: destination(markdown:)
            )
    }

    /// NavigationStack の Root 画面
    func root() -> some View {
        ProposalDetailView(
            path: $detailPath,
            markdown: markdown
        )
        .onChange(of: initialTint, initial: true) { _, color in
            tintColor = color
        }
    }

    /// 詳細画面内のリンクURLタップ時に、該当のURLで別途詳細画面を表示する
    func destination(markdown: Markdown) -> some View {
        ProposalDetailView(
            path: $detailPath,
            markdown: markdown
        )
        .onChange(of: accentColor(markdown), initial: true) { _, color in
            tintColor = color
        }
    }

    /// コンテンツのステータスに対応した色
    var initialTint: Color {
        markdown.proposal.state?.color ?? .darkText
    }

    func accentColor(_ markdown: Markdown) -> Color {
        markdown.proposal.state?.color ?? .darkText
    }
}

#if DEBUG
#Preview {
    PreviewContainer {
        ContentDetailView(
            markdown: .fake0418,
            horizontal: .compact,
            tintColor: .constant(.green)
        )
    }
}
#endif
