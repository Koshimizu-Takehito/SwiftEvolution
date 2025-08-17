// MARK: - Status

public struct Status: Codable, Hashable, Sendable {
    public var state: String
    public var version: String
    public var end: String
    public var start: String

    public init(state: String = "", version: String = "", end: String = "", start: String = "") {
        self.state = state
        self.version = version
        self.end = end
        self.start = start
    }
}

extension Status {
    public enum CodingKeys: CodingKey {
        case state
        case version
        case end
        case start
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.state = try container.decode(String.self, forKey: .state)
        self.version = (try? container.decode(String.self, forKey: .version)) ?? ""
        self.end = (try? container.decode(String.self, forKey: .end)) ?? ""
        self.start = (try? container.decode(String.self, forKey: .start)) ?? ""
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.state, forKey: .state)
        try container.encodeIfPresent(self.version, forKey: .version)
        try container.encodeIfPresent(self.end, forKey: .end)
        try container.encodeIfPresent(self.start, forKey: .start)
    }
}
