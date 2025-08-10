import Markdown
import MarkdownUI
import Splash
import SwiftData
import SwiftUI
import Observation

// MARK: - DetailView
struct ProposalDetailView: View {
    /// NavigationPath
    @Binding var path: NavigationPath
    /// ViewModel
    @State private var viewModel: ProposalDetailViewModel
    /// マークダウン再取得トリガー
    @State private var refresh: UUID?
    /// An action that opens a URL.
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollViewReader { proxy in
            List {
                let items = viewModel.items
                ForEach(items) { row in
                    MarkdownUI.Markdown(row.markup)
                }
                .modifier(MarkdownStyleModifier())
                .opacity(items.isEmpty ? 0 : 1)
                .animation(viewModel.translating ? nil : .default, value: items)
                .environment(\.openURL, openURLAction(with: proxy))
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 8))
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, 1)
        }
        .toolbar {
            ProposalDetailToolbar(viewModel: viewModel)
        }
        .overlay {
            ErrorView(error: viewModel.fetcherror) {
                refresh = .init()
            }
        }
        .task(id: refresh) {
            guard refresh != nil else { return }
            await viewModel.fetchText()
        }
        .navigationTitle(viewModel.title)
        .iOSNavigationBarTitleDisplayMode(.inline)
        .tint(viewModel.tint)
    }
}

extension ProposalDetailView {
    init(path: Binding<NavigationPath>, markdown: Markdown, context: ModelContext) {
        self.init(path: path, viewModel: .init(markdown: markdown, context: context))
    }
}

private extension ProposalDetailView {
    func openURLAction(with proxy: ScrollViewProxy) -> OpenURLAction {
        OpenURLAction { url in
            switch viewModel.makeURLAction(url: url) {
            case .scrollTo(let id):
                withAnimation { proxy.scrollTo(id, anchor: .top) }
            case .showMarkdown(let markdown):
                path.append(markdown)
            case .open:
                return .systemAction
            }
            return .discarded
        }
    }
}

#if DEBUG
#Preview {
    PreviewContainer { context in
        NavigationStack {
            ProposalDetailView(path: .fake, markdown: .fake0418, context: context)
        }
    }
    .colorScheme(.dark)
}
#endif
