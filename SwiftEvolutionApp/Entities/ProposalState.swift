import SwiftUI

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

extension ProposalState {
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
            .red
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

extension ProposalState? {
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
            ("rgba(10,132,255,1)", "rgba(0,122,255,1)")
        }
    }
}
