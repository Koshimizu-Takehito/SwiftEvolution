// MARK: - Proposal
struct Proposal: Codable, Hashable, Identifiable {
    var id: ProposalID
    var link: ProposalLink
    var status: Status
    var title: String

    var state: ProposalState? {
        ProposalState(rawValue: status.state)
    }
}

extension Proposal {
    init(_ object: ProposalObject) {
        self.id = object.id
        self.link = object.link
        self.status = object.status
        self.title = object.title
    }
}

// MARK: - Status
struct Status: Codable, Hashable {
    var state: String = ""
    var version: String = ""
    var end: String = ""
    var start: String = ""
}

extension Status {
    enum CodingKeys: CodingKey {
        case state
        case version
        case end
        case start
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.state = try container.decode(String.self, forKey: .state)
        self.version = (try? container.decode(String.self, forKey: .version)) ?? ""
        self.end = (try? container.decode(String.self, forKey: .end)) ?? ""
        self.start = (try? container.decode(String.self, forKey: .start)) ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.state, forKey: .state)
        try container.encodeIfPresent(self.version, forKey: .version)
        try container.encodeIfPresent(self.end, forKey: .end)
        try container.encodeIfPresent(self.start, forKey: .start)
    }
}
