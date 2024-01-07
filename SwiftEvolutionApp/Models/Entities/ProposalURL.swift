import SwiftUI

struct ProposalURL: Hashable {
    var proposal: Proposal
    var url: MarkdownURL?
}

extension ProposalURL {
    init(_ proposal: Proposal) {
        self.init(proposal: proposal, url: nil)
    }

    init(_ proposal: ProposalObject, _ url: MarkdownURL? = nil) {
        self.init(proposal: .init(proposal), url: url)
    }
}
