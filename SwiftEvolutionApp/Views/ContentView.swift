import SwiftUI

struct ContentView: View {
    @Environment(ProposalList.self) private var model
    @Environment(ProposalStateOptions.self) private var options
    @State private var proposal: Proposal?
    @State private var proposals: [Proposal] = []
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(proposals) { proposal in
                    NavigationLink(value: ProposalURL(proposal)) {
                        ItemView(item: proposal)
                    }
                }
            }
            .navigationDestination(for: ProposalURL.self) { pair in
                let proposal = pair.proposal
                let markdown = Markdown(proposal: proposal, url: pair.url)
                MarkdownView(markdown: markdown, path: $path)
                    .onChange(of: proposal, initial: true) { _, new in
                        self.proposal = new
                    }
                    .tint(proposal.state?.color)
            }
            .navigationTitle("Swift Evolution")
            .toolbar {
                ProposalStatePicker()
                    .opacity(model.proposals.isEmpty ? 0 : 1)
                    .tint(Color(UIColor.label))
            }
            .overlay {
                if let error = model.error as? URLError {
                    ContentUnavailableView {
                        Label("Connection issue", systemImage: "wifi.slash")
                    } description: {
                        Text(error.localizedDescription)
                    }
                }
            }
        }
        .tint(proposal?.state?.color)
        .onChange(of: model.proposals) { _, _ in update() }
        .onChange(of: options.values) { _, _ in update() }
    }

    func update() {
        withAnimation {
            let selected = options.selectedOptions()
            proposals = model.proposals.filter { proposal in
                proposal.state.map(selected.contains(_:)) ?? false
            }
        }
    }
}

private struct ItemView: View {
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

#Preview {
    ContentView()
        .environment(ProposalList())
        .environment(ProposalStateOptions())
}
