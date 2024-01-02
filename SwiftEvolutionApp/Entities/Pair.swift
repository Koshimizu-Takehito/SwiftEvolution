import SwiftUI

struct Pair<V1, V2> {
    var _0: V1
    var _1: V2

    init(_ v1: V1, _ v2: V2) {
        (_0, _1) = (v1, v2)
    }
}

extension Pair: Equatable where V1: Equatable, V2: Equatable {}
extension Pair: Hashable where V1: Hashable, V2: Hashable {}

typealias ProposalURL = Pair<Proposal, MarkdownURL?>
extension ProposalURL {
    var proposal: Proposal {
        get { _0 }
        set { _0 = newValue }
    }
    var url: MarkdownURL? {
        get { _1 }
        set { _1 = newValue }
    }

    init(_ proposal: Proposal, _ url: MarkdownURL? = nil) {
        (_0, _1) = (proposal, url)
    }
}
