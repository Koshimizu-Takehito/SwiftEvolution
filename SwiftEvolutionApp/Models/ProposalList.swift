import SwiftUI
import Observation

/// a list of all the current and upcoming proposal reviews.
@Observable
final class ProposalList {
    private(set) var proposals: [Proposal] = []
    private var dictionary: [Proposal.ID: Proposal] = [:]

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
        self.dictionary = Dictionary(uniqueKeysWithValues: proposals.map { ($0.id, $0) })
    }

    func proposal(id: Proposal.ID) -> Proposal? {
        dictionary[id]
    }
}
