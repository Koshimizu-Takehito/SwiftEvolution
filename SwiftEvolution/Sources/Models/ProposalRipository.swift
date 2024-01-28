import Foundation

actor ProposalRipository {
    let url = URL(
        string: "https://download.swift.org/swift-evolution/proposals.json"
    )!

    func fetch() async throws -> [Proposal] {
        let (data, _) = try await URLSession.shared.data(from: url)
        var values = try JSONDecoder().decode([Proposal].self, from: data)
        for (offset, proposal) in values.enumerated() {
            values[offset].title = proposal.title.trimmingCharacters(in: .whitespaces)
        }
        return values
    }
}
