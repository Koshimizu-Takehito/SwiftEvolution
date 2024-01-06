import SwiftUI

struct ProposalURL: Hashable {
    var proposal: Proposal
    var url: MarkdownURL?
}

extension ProposalURL {
    init(_ proposal: ProposalObject, _ url: MarkdownURL? = nil) {
        self.init(proposal: .init(proposal), url: url)
    }
}
