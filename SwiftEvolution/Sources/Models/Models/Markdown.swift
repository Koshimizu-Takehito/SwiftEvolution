import SwiftUI
import Observation

@Observable
final class Markdown {
    let proposal: Proposal
    let url: MarkdownURL
    private var markdown: String?

    init(proposal: Proposal, url: MarkdownURL? = nil) {
        self.proposal = proposal
        self.url = url ?? MarkdownURL(link: proposal.link)
    }

    convenience init(url: ProposalURL) {
        self.init(proposal: url.proposal, url: url.url)
    }

    func fetch() async throws {
        markdown = try await MarkdownRipository(url: url).fetch()
    }

    func buildHTML(highlight: SyntaxHighlight) async throws -> String {
        if let markdown {
            let builder = HTMLBuilder(proposal: proposal, markdown: markdown, highlight: highlight)
            return await builder.buildHTML()
        } else {
            try await fetch()
            return try await buildHTML(highlight: highlight)
        }
    }
}
