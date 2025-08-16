import EvolutionCore

extension Proposal {
    public init(_ object: ProposalObject) {
        self.init(
            id: object.proposalID,
            link: object.link,
            status: object.status,
            title: object.title
        )
    }
}
