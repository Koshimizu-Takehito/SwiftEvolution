// MARK: - Proposal
struct Proposal: Codable, Hashable, Identifiable {
    var id: ProposalID
    var authors: [ReviewManager]
    var link: ProposalLink
    var reviewManager: ReviewManager
    var sha: String
    var status: Status
    var summary: String
    var title: String
    var trackingBugs: [TrackingBug]?
    var warnings: [Warning]?
    var implementation: [Implementation]?

    var state: ProposalState? {
        ProposalState(rawValue: status.state)
    }
}

extension Proposal {
    init(_ object: ProposalObject) {
        self.id = object.id
        self.authors = object.authors
        self.link = object.link
        self.reviewManager = object.reviewManager
        self.sha = object.sha
        self.status = object.status
        self.summary = object.summary
        self.title = object.title
        self.trackingBugs = object.trackingBugs
        self.warnings = object.warnings
        self.implementation = object.implementation
    }
}

// MARK: - ReviewManager
struct ReviewManager: Codable, Hashable {
    var link: String
    var name: String
}

// MARK: - Implementation
struct Implementation: Codable, Hashable, Identifiable {
    var account: String
    var id: String
    var repository: String
    var type: String
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

// MARK: - TrackingBug
struct TrackingBug: Codable, Hashable, Identifiable {
    var assignee: String
    var id: String
    var link: String
    var radar: String
    var resolution: String
    var status: String
    var title: String
    var updated: String
}

// MARK: - Warning
struct Warning: Codable, Hashable {
    var kind: String
    var message: String
    var stage: String
}
