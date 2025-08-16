import SwiftUI

// MARK: - State

public enum ProposalStatus: String, Codable, Hashable, CaseIterable, Sendable, Identifiable, CustomStringConvertible {
    case accepted
    case activeReview
    case implemented
    case previewing
    case rejected
    case returnedForRevision
    case withdrawn

    public var id: String { rawValue }

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
    public static var allCases: Set {
        .init(Element.allCases)
    }
}

extension Set<ProposalStatus>: @retroactive RawRepresentable {
    public init?(rawValue: String) {
        guard
            let data = rawValue.data(using: .utf8),
            let result = try? JSONDecoder().decode(Self.self, from: data)
        else {
            return nil
        }
        self = result
    }

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
