import SwiftUI
import Observation

struct ContentView: View {
    @Environment(ProposalList.self) private var model
    @State private var proposal: Proposal?
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                ForEach(model.proposals) { proposal in
                    NavigationLink(value: ProposalURL(proposal)) {
                        ItemView(item: proposal)
                    }
                }
            }
            .navigationDestination(for: ProposalURL.self) { pair in
                let proposal = pair.proposal
                DetailView(model: Markdown(proposal: proposal, url: pair.url), path: $navigationPath)
                    .onChange(of: proposal, initial: true) { _, new in
                        self.proposal = new
                    }
                    .tint(proposal.state?.color)
            }
            .navigationTitle("Swift Evolution")
        }
        .tint(proposal?.state?.color)
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
}
