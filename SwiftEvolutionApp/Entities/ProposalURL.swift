import SwiftUI

struct ProposalURL: Hashable {
    var proposal: Proposal
    var url: MarkdownURL?
}

extension ProposalURL {
    init(_ proposal: Proposal, _ url: MarkdownURL? = nil) {
        self.init(proposal: proposal, url: url)
    }
}
