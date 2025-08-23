import EvolutionCore
import EvolutionUI
import Markdown
import MarkdownUI
import Observation
import SafariServices
import Splash
import SwiftData
import SwiftUI

import struct EvolutionCore.Markdown

// MARK: - ProposalDetailView

struct ProposalDetailView: View {
    /// NavigationPath
    @Binding var path: NavigationPath
    /// ViewModel
    @State private var viewModel: ProposalDetailViewModel
    /// マークダウン再取得トリガー
    @State private var refresh: UUID?
    /// コピーしたコードブロック
    @State private var copied: CopiedCode?
    /// An action that opens a URL.
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollViewReader { proxy in
            List {
                let items = viewModel.items
                ForEach(items) { item in
                    MarkdownUI.Markdown(item.markup)
                }
                .modifier(MarkdownStyleModifier())
                .opacity(items.isEmpty ? 0 : 1)
                .animation(viewModel.translating ? nil : .default, value: items)
                .environment(\.openURL, openURLAction(with: proxy))
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .onCopyToClipboard { code in
                    withAnimation { copied = code }
                    try? await Task.sleep(for: .seconds(1))
                    withAnimation { copied = nil }
                }
            }
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, 1)
        }
        .toolbar {
            NavigationBar(viewModel: viewModel)
        }
        .overlay {
            ErrorView(error: viewModel.fetcherror) {
                refresh = .init()
            }
        }
        .overlay {
            CopiedHUD(copied: copied)
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

extension ProposalDetailView {
    fileprivate func openURLAction(with proxy: ScrollViewProxy) -> OpenURLAction {
        OpenURLAction { url in
            switch viewModel.makeURLAction(url: url) {
            case .scrollTo(let id):
                withAnimation { proxy.scrollTo(id, anchor: .top) }
            case .showMarkdown(let markdown):
                path.append(markdown)
            case .open:
                showSafariView(url: url)
            }
            return .discarded
        }
    }

    /// SFSafariViewController で Web コンテンツを表示
    @MainActor
    fileprivate func showSafariView(url: URL) {
        guard url.scheme?.contains(/^https?$/) == true else { return }
        #if os(macOS)
            NSWorkspace.shared.open(url)
        #elseif os(iOS)
            let safari = SFSafariViewController(url: url)
            UIApplication.shared
                .connectedScenes
                .lazy
                .compactMap { $0 as? UIWindowScene }
                .first?
                .keyWindow?
                .rootViewController?
                .show(safari, sender: self)
        #endif
    }
}

#Preview(traits: .proposal) {
    @Previewable @Environment(\.modelContext) var context
    NavigationStack {
        ProposalDetailView(
            path: Binding.fake,
            markdown: .fake0465,
            context: context
        )
    }
    .colorScheme(.dark)
}
