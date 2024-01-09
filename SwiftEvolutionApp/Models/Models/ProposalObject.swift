import SwiftUI
import SwiftData

typealias ProposalID = String
typealias ProposalLink = String

// MARK: - ProposalObject
@Model
final class ProposalObject {
    @Attribute(.unique) var id: ProposalID
    var authors: [ReviewManager]
    var link: ProposalLink
    var reviewManager: ReviewManager
    var sha: String
    var status: Status
    var summary: String
    var title: String
    var trackingBugs: [TrackingBug]
    var warnings: [Warning]
    var implementation: [Implementation]
    var isBookmarked: Bool

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
        implementation: [Implementation]?,
        isBookmarked: Bool
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
        self.isBookmarked = isBookmarked
    }
}

extension ProposalObject {
    var state: ProposalState? {
        ProposalState(rawValue: status.state)
    }

    @MainActor
    static func fetch(context: ModelContext) async throws {
        // APIからプロポーザルを取得
        let values = try await Task.detached {
            let url = URL(string: "https://download.swift.org/swift-evolution/proposals.json")!
            let (data, _) = try await URLSession.shared.data(from: url)
            var values = try JSONDecoder().decode([Proposal].self, from: data)
            for (offset, proposal) in values.enumerated() {
                values[offset].title = proposal.title.trimmingCharacters(in: .whitespaces)
            }
            return values
        }.value

        // APIから取得した結果をマージ・保存
        let objects = Dictionary(
            self.objects(in: context).map { ($0.id, $0) },
            uniquingKeysWith: { _, rhs in rhs }
        )
        values.forEach { value in
            if let object = objects[value.id] {
                object.update(with: value)
            } else {
                let object = ProposalObject(value: value, isBookmarked: false)
                context.insert(object)
            }
        }
    }

    static func objects(in context: ModelContext) -> [ProposalObject] {
        (try? context.fetch(FetchDescriptor<ProposalObject>())) ?? []
    }

    static func find(by id: ProposalID, in context: ModelContext) -> ProposalObject? {
        let predicate = #Predicate<ProposalObject> {
            $0.id == id
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try? context.fetch(descriptor).first
    }

    static func query(states: Set<ProposalState>, isBookmarked: Bool) -> Query<ProposalObject, [ProposalObject]> {
        Query(
            filter: predicate(states: states, isBookmarked: isBookmarked),
            sort: \.id,
            order: .reverse,
            animation: .default
        )
    }

    static func predicate(states: Set<ProposalState>, isBookmarked: Bool) -> Predicate<ProposalObject> {
        let states = Set(states.map(\.rawValue))
        return #Predicate<ProposalObject> { proposal in
            states.contains(proposal.status.state)
            && (!isBookmarked || proposal.isBookmarked == isBookmarked)
        }
    }
}

private extension ProposalObject {
    convenience init(value: Proposal, isBookmarked: Bool) {
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
            implementation: value.implementation,
            isBookmarked: isBookmarked
        )
    }

    func update(with value: Proposal) {
        authors = value.authors
        link = value.link
        reviewManager = value.reviewManager
        sha = value.sha
        status = value.status
        summary = value.summary
        title = value.title
        trackingBugs = value.trackingBugs ?? []
        warnings = value.warnings ?? []
        implementation = value.implementation ?? []
    }
}

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
