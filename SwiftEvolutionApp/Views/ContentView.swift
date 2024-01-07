import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var path = NavigationPath()
    @State private var error: Error?
    @State private var proposal: Proposal?
    @State private var states = Set<ProposalState>.allCases
    @State private var refreshRrigger = UUID()
    @Query(animation: .default) private var proposals: [ProposalObject]
    @Environment(\.modelContext) private var context
    @Environment(ProposalStateOptions.self) private var options

    var body: some View {
        NavigationStack(path: $path) {
            // リスト画面
            ProposalListView(path: $path, states: states)
                .overlay {
                    if let error {
                        ErrorView(error: error, retry: retry)
                    }
                }
                .navigationDestination(for: ProposalURL.self) { pair in
                    // 詳細画面
                    let proposal = pair.proposal
                    let markdown = Markdown(proposal: proposal, url: pair.url)
                    MarkdownView(markdown: markdown, path: $path)
                        .onChange(of: proposal, initial: true) {
                            self.proposal = proposal
                        }
                        .tint(proposal.state?.color)
                }
                .toolbar {
                    if !proposals.isEmpty {
                        ProposalStatePicker()
                            .tint(Color(UIColor.label))
                    }
                }
        }
        .tint(proposal?.state?.color)
        .task(id: refreshRrigger) { await refresh() }
        .onChange(of: options.currentOption) { filter() }
    }
}

private extension ContentView {
    @MainActor
    func refresh() async {
        withAnimation { self.error = nil }
        do {
            try await ProposalObject.fetch(context: context)
        } catch {
            if proposals.isEmpty {
                withAnimation { self.error = error }
            }
        }
    }

    func retry() {
        refreshRrigger = .init()
    }

    func filter() {
        withAnimation {
            states = options.currentOption
        }
    }
}

#Preview {
    PreviewContainer {
        ContentView()
    }
}
