import EvolutionCore

// MARK: - Proposal + Persistence

/// Convenience initializers that bridge between ``Proposal`` values and their
/// stored ``ProposalObject`` counterparts.
extension Proposal {
    /// Creates a ``Proposal`` instance from a stored ``ProposalObject``.
    ///
    /// - Parameter object: The persistent model representing a proposal.
    public init(_ object: ProposalObject) {
        self.init(
            id: object.proposalID,
            link: object.link,
            status: object.status,
            title: object.title
        )
    }
}
