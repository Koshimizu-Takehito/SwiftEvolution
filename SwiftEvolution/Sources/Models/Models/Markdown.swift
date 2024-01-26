import SwiftUI
import Observation

@Observable
final class Markdown {
    let proposal: Proposal
    let url: MarkdownURL
    private var markdown: String?
    private(set) var html: String?

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

    func buildHTML(highlight: SyntaxHighlight) async throws {
        if let markdown {
            let builder = HTMLBuilder(proposal: proposal, markdown: markdown, highlight: highlight)
            html = await builder.buildHTML()
        } else {
            try await fetch()
            try await buildHTML(highlight: highlight)
        }
    }
}
