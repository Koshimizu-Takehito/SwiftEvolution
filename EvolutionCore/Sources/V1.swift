// MARK: - V1

/// Top-level structure of the `evolution.json` feed.
public struct V1: Codable, Hashable, Sendable {
    /// SHA hash of the commit that produced the feed.
    public var commit: String
    /// ISO-8601 creation timestamp for the feed.
    public var creationDate: String
    /// Swift versions that currently ship the included proposals.
    public var implementationVersions: [String]
    /// All proposals listed in the feed.
    public var proposals: [Proposal]
}
