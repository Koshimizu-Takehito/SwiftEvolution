import SwiftUI

// MARK: -
/// SplitView の Detail View
///
/// Detail View 側のナビゲーションスタックの管理を行う
struct ContentDetailView: View {
    /// 詳細画面のNavigationPath
    @State private var detailPath = NavigationPath()
    /// 詳細画面のコンテンツURL
    let url: ProposalURL
    /// 水平サイズクラス
    let horizontal: UserInterfaceSizeClass?
    /// ナビゲーションバーの現在の色合い
    @Binding var tintColor: Color?

    var body: some View {
        NavigationStack(path: $detailPath, root: root)
            .navigationDestination(
                for: ProposalURL.self,
                destination: destination(url:)
            )
    }

    /// NavigationStack の Root 画面
    func root() -> some View {
        Group {
            switch (horizontal, tintColor) {
            case (.compact, .none):
                // compact の場合は tint の設定まで描画を遅延
                EmptyView()
            case (_, _):
                // tint の設定後に、コンテンツURLに対応した詳細画面を表示
                ProposalDetailView(path: $detailPath, url: url)
            }
        }
        .onChange(of: initialTint, initial: true) { _, color in
            tintColor = color
        }
    }

    /// 詳細画面内のリンクURLタップ時に、該当のURLで別途詳細画面を表示する
    func destination(url: ProposalURL) -> some View {
        ProposalDetailView(
            path: $detailPath,
            tint: $tintColor,
            url: url
        )
    }

    /// コンテンツのステータスに対応した色
    var initialTint: Color {
        url.proposal.state?.color ?? .darkText
    }
}

#Preview {
    PreviewContainer {
        ContentDetailView(
            url: .fake0418,
            horizontal: .compact,
            tintColor: .constant(.green)
        )
    }
}
