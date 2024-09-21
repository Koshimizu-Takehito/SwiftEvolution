import Foundation

actor ProposalRipository {
    let url = URL(string: "https://download.swift.org/swift-evolution/v1/evolution.json")!

    func fetch() async throws -> [Proposal] {
        let (data, _) = try await URLSession.shared.data(from: url)
        let v1 = try JSONDecoder().decode(V1.self, from: data)
        var values = v1.proposals
        for (offset, proposal) in values.enumerated() {
            values[offset].title = proposal.title.trimmingCharacters(in: .whitespaces)
        }
        return values
    }
}
