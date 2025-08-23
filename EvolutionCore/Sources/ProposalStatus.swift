import SwiftUI

// MARK: - State

/// Enumerates the possible lifecycle states for a Swift Evolution proposal.
public enum ProposalStatus: String, Codable, Hashable, CaseIterable, Sendable, Identifiable, CustomStringConvertible {
    case accepted
    case activeReview
    case implemented
    case previewing
    case rejected
    case returnedForRevision
    case withdrawn

    /// Conformance to `Identifiable`.
    public var id: String { rawValue }

    /// Human-friendly name displayed to users.
    public var description: String {
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

// MARK: - Set

extension Set<ProposalStatus> {
    /// Convenience property that returns a set containing every possible case.
    public static var allCases: Set {
        .init(Element.allCases)
    }
}

extension Set<ProposalStatus>: @retroactive RawRepresentable {
    /// Creates a set from its JSON string representation.
    public init?(rawValue: String) {
        guard
            let data = rawValue.data(using: .utf8),
            let result = try? JSONDecoder().decode(Self.self, from: data)
        else {
            return nil
        }
        self = result
    }

    /// Converts the set into a JSON string representation.
    public var rawValue: String {
        guard
            let data = try? JSONEncoder().encode(self),
            let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
