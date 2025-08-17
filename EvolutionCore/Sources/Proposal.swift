// MARK: - Proposal

public struct Proposal: Codable, Hashable, Identifiable, Sendable {
    public var id: String
    public var link: String
    public var status: Status
    public var title: String

    public var state: ProposalStatus? {
        ProposalStatus(rawValue: status.state)
    }

    public init(id: String, link: String, status: Status, title: String) {
        self.id = id
        self.link = link
        self.status = status
        self.title = title
    }
}
