import Foundation

/// Loads the list of proposals from the Swift Evolution website.
public actor ProposalRipository {
    /// Location of the JSON feed describing all proposals.
    let url = URL(string: "https://download.swift.org/swift-evolution/v1/evolution.json")!

    public init() {}

    /// Retrieves and decodes the proposal list from the remote feed.
    /// - Returns: All proposals currently published by Swift Evolution.
    public func fetch() async throws -> [Proposal] {
        let (data, _) = try await URLSession.shared.data(from: url)
        let v1 = try JSONDecoder().decode(V1.self, from: data)
        var values = v1.proposals
        for (offset, proposal) in values.enumerated() {
            values[offset].title = proposal.title.trimmingCharacters(in: .whitespaces)
        }
        return values
    }
}
