import Markdown
import Foundation

struct ProposalDetailRow: Hashable, Identifiable {
    var id: String
    var markup: String
}

extension [ProposalDetailRow] {
    init(markdown: Markdown) {
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
