import SwiftUI

struct ProposalDetailToolbar: ToolbarContent {
    /// ViewModel
    @Bindable var viewModel: ProposalDetailViewModel
    /// 表示コンテンツで利用するシンタックスハイライト
    @AppStorage<SyntaxHighlight> private var highlight = .xcodeDark

    @ToolbarContentBuilder
    var body: some ToolbarContent {
        ToolbarItem {
            BookmarkButton(isBookmarked: $viewModel.isBookmarked)
        }
        ToolbarSpacer()
        ToolbarItemGroup {
#if os(iOS) || os(iPadOS)
            translateButton()
            settingsMenu()
#else
            Picker(selection: $highlight) {
                ForEach(SyntaxHighlight.allCases) { item in
                    Text(item.displayName)
                        .tag(item)
                }
            } label: {
                Image(systemName: "gearshape")
            }
#endif
        }
    }

    @ViewBuilder
    func translateButton() -> some View {
        if !viewModel.translating {
            Button("翻訳", systemImage: "character.bubble") {
                Task { try await viewModel.translate() }
            }
        } else {
            ZStack {
                Button("翻訳", systemImage: "character.bubble") {}
                    .hidden()
                ProgressView()
            }
        }
    }

    @ViewBuilder
    func settingsMenu() -> some View {
        Menu("Settings", systemImage: "gearshape") {
            Picker("Settings", systemImage: "gearshape", selection: $highlight) {
                ForEach(SyntaxHighlight.allCases) { item in
                    Text(item.displayName)
                        .tag(item)
                }
            }
        }
    }
}
