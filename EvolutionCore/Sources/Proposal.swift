// MARK: - Proposal

/// Summary information for a Swift Evolution proposal as returned by the
/// `evolution.json` feed.
public struct Proposal: Codable, Hashable, Identifiable, Sendable {
    /// The proposal identifier, such as "SE-0001".
    public var id: String
    /// URL path to the proposal's markdown file on GitHub.
    public var link: String
    /// The current review status details.
    public var status: Status
    /// Human-readable proposal title.
    public var title: String

    /// Convenience accessor that converts the ``status`` value into a
    /// ``ProposalStatus`` enumeration.
    public var state: ProposalStatus? {
        ProposalStatus(rawValue: status.state)
    }

    /// Creates a new ``Proposal`` instance.
    /// - Parameters:
    ///   - id: The proposal identifier.
    ///   - link: URL path to the proposal details.
    ///   - status: The current review status metadata.
    ///   - title: Human-friendly title text.
    public init(id: String, link: String, status: Status, title: String) {
        self.id = id
        self.link = link
        self.status = status
        self.title = title
    }
}
