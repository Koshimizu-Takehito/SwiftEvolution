import Markdown
import Foundation
import EvolutionCore

/// A single row of formatted markdown in the proposal detail screen.
public struct ProposalDetailRow: Hashable, Identifiable {
    /// Identifier used for navigation and hashing.
    public var id: String
    /// HTML markup representing the row's contents.
    public var markup: String

    public init(id: String, markup: String) {
        self.id = id
        self.markup = markup
    }
}

extension [ProposalDetailRow] {
    /// Creates an array of rows by parsing the proposal's markdown document.
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
