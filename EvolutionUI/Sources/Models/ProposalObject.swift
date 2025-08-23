import EvolutionCore
import EvolutionModel
import SwiftData
import SwiftUI

extension Query<ProposalObject, [ProposalObject]> {
    public static func query(status: Set<ProposalStatus>, isBookmarked: Bool) -> Query {
        Query(
            filter: .predicate(states: status, isBookmarked: isBookmarked),
            sort: \.proposalID,
            order: .reverse,
            animation: .default
        )
    }
}

extension Predicate<ProposalObject> {
    public static func predicate(states: Set<ProposalStatus>, isBookmarked: Bool) -> Predicate<ProposalObject> {
        let states = Set(states.map(\.rawValue))
        return #Predicate { proposal in
            states.contains(proposal.status.state)
                && (!isBookmarked || proposal.isBookmarked == isBookmarked)
        }
    }

    public static var bookmark: Predicate<ProposalObject> {
        #Predicate { $0.isBookmarked }
    }
}
