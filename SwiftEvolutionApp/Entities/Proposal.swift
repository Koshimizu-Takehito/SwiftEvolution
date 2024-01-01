import SwiftUI

// MARK: - Proposal
struct Proposal: Codable, Hashable, Identifiable {
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
    var state: String
    var version: String?
    var end: String?
    var start: String?
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

extension Proposal {
    var state: ProposalState? {
        ProposalState(rawValue: status.state)
    }
}
