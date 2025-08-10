import Markdown
import MarkdownUI
import Splash
import SwiftData
import SwiftUI
import Observation

import struct Markdown.Heading
import struct Markdown.Link

// MARK: - DetailView
struct ProposalDetailView: View {
    /// NavigationPath
    @Binding var path: NavigationPath
    /// ViewModel
    @State private var viewModel: ProposalDetailViewModel
    /// 該当コンテンツのブックマーク有無
    @State private var isBookmarked: Bool = false
    /// マークダウン再取得トリガー
    @State private var refresh: UUID?

    @Environment(\.openURL) private var openURL


    init(path: Binding<NavigationPath>, markdown: Markdown, context: ModelContext) {
        _path = path
        _viewModel = .init(initialValue: .init(markdown: markdown, context: context))
    }

    @ViewBuilder
    var markdownView: some View {
        let markdownString = viewModel.markdown.text ?? ""
        let document = Document(parsing: markdownString)
        var idCount = [String: Int]()
        let contents = Array(document.children.enumerated()).map { offset, content -> (markup: any Markup, id: String) in
            if let heading = content as? Heading {
                let heading = heading.format()
                let id = ProposalDetailViewModel.htmlID(fromMarkdownHeader: heading)
                let count = idCount[id]
                let _ = {
                    idCount[id] = (count ?? 0) + 1
                }()
                return (content, count.map { "\(id)-\($0)" } ?? id)
            } else {
                return (content, "\(offset)")
            }
        }
        ForEach(contents, id: \.id) { markup, id in
            MarkdownUI.Markdown(markup.format())
        }
        .modifier(MarkdownStyleModifier())
        .opacity(markdownString.isEmpty ? 0 : 1)
        .animation(viewModel.translating ? nil : .default, value: markdownString)
    }

    var body: some View {
        ScrollViewReader { proxy in
            List {
                markdownView.environment(\.openURL, openURLAction(with: proxy))
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 8))
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, 1)
        }
        .toolbar {
            // ツールバー
            ProposalDetailToolbarContent(viewModel: viewModel, isBookmarked: $isBookmarked)
        }
        .onAppear {
            // ブックマークの状態を復元
            isBookmarked = viewModel.isBookmarked
        }
        .onChange(of: isBookmarked) { _, isBookmarked in
            viewModel.saveBookmark(isBookmarked: isBookmarked)
        }
        .overlay {
            // エラー画面
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
