import SwiftUI
import Observation

struct Markdown: Codable, Hashable, Identifiable {
    let proposal: Proposal
    let url: MarkdownURL
    var id: URL { url.rawValue }
    private var text: String?

    init(proposal: Proposal, url: MarkdownURL? = nil) {
        self.proposal = proposal
        self.url = url ?? MarkdownURL(link: proposal.link)
    }

    mutating func fetch() async throws {
        text = try await MarkdownRipository(url: url).fetch()
    }

    mutating func buildHTML(highlight: SyntaxHighlight) async throws -> String {
        if let text {
            let builder = HTMLBuilder(
                proposal: proposal,
                markdown: text,
                highlight: highlight
            )
            return await builder.buildHTML()
        } else {
            try await fetch()
            return try await buildHTML(highlight: highlight)
        }
    }
}
