import Foundation
import SwiftData

typealias ProposalID = String

// MARK: - Proposal
@Model
final class Proposal {
    @Attribute(.unique) var id: ProposalID
    var authors: [ReviewManager]
    var link: String
    var reviewManager: ReviewManager
    var sha: String
    var status: Status
    var summary: String
    var title: String
    var trackingBugs: [TrackingBug]
    var warnings: [Warning]
    var implementation: [Implementation]

    init(
        id: String,
        authors: [ReviewManager],
        link: String,
        reviewManager: ReviewManager,
        sha: String,
        status: Status,
        summary: String,
        title: String,
        trackingBugs: [TrackingBug]?,
        warnings: [Warning]?,
        implementation: [Implementation]?
    ) {
        self.authors = authors
        self.id = id
        self.link = link
        self.reviewManager = reviewManager
        self.sha = sha
        self.status = status
        self.summary = summary
        self.title = title
        self.trackingBugs = trackingBugs ?? []
        self.warnings = warnings ?? []
        self.implementation = implementation ?? []
    }
}

extension Proposal {
    var state: ProposalState? {
        ProposalState(rawValue: status.state)
    }

    @MainActor
    static func fetch(context: ModelContext) async throws {
        let url = URL(string: "https://download.swift.org/swift-evolution/proposals.json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        var values = try JSONDecoder().decode([Response].self, from: data)
        for (offset, proposal) in values.enumerated() {
            values[offset].title = proposal.title.trimmingCharacters(in: .whitespaces)
        }
        values.forEach { value in
            context.insert(Proposal(value))
        }
    }

    static func find(by id: ProposalID, in context: ModelContext) -> Proposal? {
        let predicate = #Predicate<Proposal> {
            $0.id == id
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try? context.fetch(descriptor).first
    }
}

private extension Proposal {
    struct Response: Codable, Hashable, Identifiable {
        var authors: [ReviewManager]
        var id: String
        var link: String
        var reviewManager: ReviewManager
        var sha: String
        var status: Status
        var summary: String
        var title: String
        var trackingBugs: [TrackingBug]?
        var warnings: [Warning]?
        var implementation: [Implementation]?
    }

    convenience init(_ value: Response) {
        self.init(
            id: value.id,
            authors: value.authors,
            link: value.link,
            reviewManager: value.reviewManager,
            sha: value.sha,
            status: value.status,
            summary: value.summary,
            title: value.title,
            trackingBugs: value.trackingBugs,
            warnings: value.warnings,
            implementation: value.implementation
        )
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
