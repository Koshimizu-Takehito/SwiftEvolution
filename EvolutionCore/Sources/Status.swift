// MARK: - Status

/// Detailed status metadata for a proposal.
public struct Status: Codable, Hashable, Sendable {
    /// Raw state string such as "activeReview" or "accepted".
    public var state: String
    /// Version of Swift in which the change shipped, if any.
    public var version: String
    /// The end date for the proposal's review period.
    public var end: String
    /// The start date for the proposal's review period.
    public var start: String

    /// Creates a new ``Status`` value with optional components.
    /// - Parameters:
    ///   - state: Raw state identifier.
    ///   - version: Swift version tied to the proposal.
    ///   - end: Review period end date.
    ///   - start: Review period start date.
    public init(state: String = "", version: String = "", end: String = "", start: String = "") {
        self.state = state
        self.version = version
        self.end = end
        self.start = start
    }
}

extension Status {
    /// Coding keys used to map JSON fields to ``Status`` properties.
    public enum CodingKeys: CodingKey {
        case state
        case version
        case end
        case start
    }

    /// Decodes the status from the Swift Evolution API, filling in missing
    /// fields with empty strings to simplify downstream handling.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.state = try container.decode(String.self, forKey: .state)
        self.version = (try? container.decode(String.self, forKey: .version)) ?? ""
        self.end = (try? container.decode(String.self, forKey: .end)) ?? ""
        self.start = (try? container.decode(String.self, forKey: .start)) ?? ""
    }

    /// Encodes the status for persistence.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.state, forKey: .state)
        try container.encodeIfPresent(self.version, forKey: .version)
        try container.encodeIfPresent(self.end, forKey: .end)
        try container.encodeIfPresent(self.start, forKey: .start)
    }
}
