import EvolutionCore
import SwiftUI

extension ProposalStatus {
    public var color: Color {
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

    public var tintColor: UIColor {
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

extension EnvironmentValues {
    @Entry public var selectedStatus: Set<ProposalStatus> = .allCases
}
