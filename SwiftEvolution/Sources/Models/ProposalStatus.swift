import SwiftUI

// MARK: - State
enum ProposalStatus: String, Codable, Hashable, CaseIterable {
    case accepted
    case activeReview
    case implemented
    case previewing
    case rejected
    case returnedForRevision
    case withdrawn
}

extension ProposalStatus: Identifiable {
    var id: String { rawValue }
}

extension ProposalStatus: CustomStringConvertible {
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

extension ProposalStatus {
    var color: Color {
        switch self {
        case .accepted:
            .green
        case .activeReview:
            .orange
        case .implemented:
            .blue
        case .previewing:
            .mint
        case .rejected:
            .red
        case .returnedForRevision:
            .purple
        case .withdrawn:
            .gray
        }
    }

    var tintColor: UIColor {
        switch self {
        case .accepted:
            .systemGreen
        case .activeReview:
            .systemOrange
        case .implemented:
            .systemBlue
        case .previewing:
            .systemMint
        case .rejected:
            .systemRed
        case .returnedForRevision:
            .systemPurple
        case .withdrawn:
            .systemRed
        }
    }
}

extension ProposalStatus? {
    var accentColor: (dark: String, light: String) {
        switch self {
        case .accepted:
            ("rgba(48,209,88,1)", "rgba(52,199,89,1)")
        case .activeReview:
            ("rgba(255,159,10,1)", "rgba(255,149,0,1)")
        case .implemented:
            ("rgba(10,132,255,1)", "rgba(0,122,255,1)")
        case .previewing:
            ("rgba(99,230,226,1)", "rgba(0,199,190,1)")
        case .rejected:
            ("rgba(255,69,58,1)", "rgba(255,59,48,1)")
        case .returnedForRevision:
            ("rgba(191,90,242,1)", "rgba(175,82,222,1)")
        case .withdrawn:
            ("rgba(255,69,58,1)", "rgba(255,59,48,1)")
        case nil:
            ("rgba(142,142,147,1)", "rgba(142,142,147,1)")
        }
    }
}

extension EnvironmentValues {
    private struct SelectedStatusKey: EnvironmentKey {
        static let defaultValue: Set<ProposalStatus> = .allCases
    }

    var selectedStatus: Set<ProposalStatus> {
        get { self[SelectedStatusKey.self] }
        set { self[SelectedStatusKey.self] = newValue }
    }
}

extension Set<ProposalStatus> {
    static var allCases: Set {
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
