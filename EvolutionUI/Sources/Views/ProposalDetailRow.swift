import Markdown
import Foundation
import EvolutionCore

public struct ProposalDetailRow: Hashable, Identifiable {
    public var id: String
    public var markup: String

    public init(id: String, markup: String) {
        self.id = id
        self.markup = markup
    }
}

extension [ProposalDetailRow] {
    public init(markdown: Markdown) {
        let markdownString = markdown.text ?? ""
        let document = Document(parsing: markdownString)
        var idCount = [String: Int]()
        self = document.children.enumerated().map { offset, content -> ProposalDetailRow in
            if let heading = content as? Heading {
                let heading = heading.format()
                let id = ProposalDetailViewModel.htmlID(fromMarkdownHeader: heading)
                let count = idCount[id]
                let _ = {
                    idCount[id] = (count ?? 0) + 1
                }()
                return ProposalDetailRow(id: count.map { "\(id)-\($0)" } ?? id, markup: heading)
            } else {
                return ProposalDetailRow(id: "\(offset)", markup: content.format())
            }
        }
    }
}
