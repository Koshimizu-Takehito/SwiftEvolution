// MARK: - V1

public struct V1: Codable, Hashable, Sendable {
    public var commit: String
    public var creationDate: String
    public var implementationVersions: [String]
    public var proposals: [Proposal]
}
