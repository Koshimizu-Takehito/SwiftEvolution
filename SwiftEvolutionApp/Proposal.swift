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

// MARK: - State
enum ProposalState: String, Codable, Hashable, CaseIterable, CustomStringConvertible {
    case accepted = ".accepted"
    case activeReview = ".activeReview"
    case implemented = ".implemented"
    case previewing = ".previewing"
    case rejected = ".rejected"
    case returnedForRevision = ".returnedForRevision"
    case withdrawn = ".withdrawn"

    var description: String {
        switch self {
        case .accepted:
            "Accepted"
        case .activeReview:
            "Active Review"
        case .implemented:
            "Implemented"
        case .previewing:
            "Previewing"
        case .rejected:
            "Rejected"
        case .returnedForRevision:
            "Returned"
        case .withdrawn:
            "Withdrawn"
        }
    }
}

extension Proposal {
    var state: ProposalState? {
        ProposalState(rawValue: status.state)
    }
}
