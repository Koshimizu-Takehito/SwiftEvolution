import SwiftUI
import Observation

/// a list of all the current and upcoming proposal reviews.
@Observable
final class ProposalList {
    private(set) var proposals: [Proposal] = []

    init() {
        Task { try await fetch() }
    }

    func fetch() async throws {
        let url = URL(string: "https://download.swift.org/swift-evolution/proposals.json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        var proposals = try JSONDecoder().decode([Proposal].self, from: data)
        for (offset, proposal) in proposals.enumerated() {
            proposals[offset].title = proposal.title.trimmingCharacters(in: .whitespaces)
        }
        self.proposals = proposals.reversed()
    }
}

struct ContentView: View {
    @State private var model = ProposalList()
    @State private var proposal: Proposal?

    var body: some View {
        NavigationStack {
            List {
                ForEach(model.proposals) { proposal in
                    NavigationLink(value: proposal) {
                        ItemView(item: proposal)
                    }
                }
            }
            .navigationDestination(for: Proposal.self) { proposal in
                DetailView(model: Markdown(proposal: proposal))
                    .onChange(of: proposal, initial: true) { _, new in
                        self.proposal = new
                    }
                    .tint(proposal.state?.color)
            }
            .navigationTitle("Swift Evolution")
        }
        .tint(proposal?.state?.color)
        .task {
            try? await model.fetch()
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

extension ProposalState {
    var color: Color {
        switch self {
        case .accepted:
            .green
        case .activeReview:
            .orange
        case .implemented:
            .blue
        case .previewing:
            .mint
        case .rejected:
            .red
        case .returnedForRevision:
            .purple
        case .withdrawn:
            .red
        }
    }
}

#Preview {
    ContentView()
}
