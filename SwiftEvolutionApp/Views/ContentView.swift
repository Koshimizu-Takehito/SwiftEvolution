import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var path = NavigationPath()
    @State private var error: Error?
    @State private var proposal: Proposal?
    @State private var states = Set<ProposalState>.allCases
    @Query(animation: .default) private var proposals: [ProposalObject]
    @Environment(\.modelContext) private var context
    @Environment(ProposalStateOptions.self) private var options

    var body: some View {
        NavigationStack(path: $path) {
            // リスト画面
            ProposalListView(path: $path, states: states)
                .overlay {
                    if let error {
                        ProposalListErrorView(error: error)
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
        .task { await refresh() }
        .onChange(of: options.currentOption) { filter() }
    }

    @MainActor
    func refresh() async {
        do {
            try await ProposalObject.fetch(context: context)
        } catch {
            if proposals.isEmpty {
                self.error = error
            }
        }
    }

    func filter() {
        withAnimation {
            states = options.currentOption
        }
    }
}

// MARK: - ProposalListView
private struct ProposalListView: View {
    @Binding var path: NavigationPath
    @Query private var proposals: [ProposalObject]

    init(path: Binding<NavigationPath>, states: Set<ProposalState>) {
        _path = path
        _proposals = ProposalObject.query(states: states)
    }

    var body: some View {
        List {
            ForEach(proposals) { proposal in
                NavigationLink(value: ProposalURL(proposal)) {
                    ProposalItemView(item: .init(proposal))
                }
            }
        }
        .navigationTitle("Swift Evolution")
    }
}

// MARK: - ProposalItemView
private struct ProposalItemView: View {
    let item: Proposal

    var body: some View {
        VStack(alignment: .leading) {
            StateView(state: item.state)

            Text(item.id)
                .foregroundStyle(.secondary)
            + Text(" ")
            + Text(item.title)
                .foregroundStyle(.primary)
        }
    }
}

// MARK: - StateView
private struct StateView: View {
    let state: ProposalState?

    var body: some View {
        if let state {
            Text(String(describing: state))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .overlay {
                    RoundedRectangle(cornerRadius: 4, style: .circular)
                        .stroke()
                }
                .foregroundStyle(state.color)
        }
    }
}

// MARK: - ProposalListErrorView
private struct ProposalListErrorView: View {
    let error: Error

    var body: some View {
        ContentUnavailableView {
            Label("Connection issue", systemImage: "wifi.slash")
        } description: {
            Text(error.localizedDescription)
        }
    }
}

#Preview {
    ContentView()
        .environment(ProposalStateOptions())
}
