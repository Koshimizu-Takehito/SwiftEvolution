import SwiftUI
import Observation

@Observable
final class Markdown {
    let proposal: Proposal
    let url: MarkdownURL?
    var highlight = SyntaxHighlight.current {
        didSet {
            SyntaxHighlight.current = highlight
            buildHTML()
        }
    }
    private(set) var markdown = ""
    private(set) var html: String?

    init(proposal: Proposal, url: MarkdownURL? = nil) {
        self.proposal = proposal
        self.url = url
        Task { try await self.fetch() }
    }

    convenience init(url: ProposalURL) {
        self.init(proposal: url.proposal, url: url.url)
    }
}

private extension Markdown {
    private func fetch() async throws {
        let url = url ?? MarkdownURL(link: proposal.link)
        let (data, _) = try await URLSession.shared.data(from: url.rawValue)
        markdown = (String(data: data, encoding: .utf8) ?? "")
            .replacingOccurrences(of: "\n", with: #"\n"#)
            .replacingOccurrences(of: "'", with: #"\'"#)
        buildHTML()
    }

    var githubMarkdownCss: String {
        let (dark, light) = proposal.state.accentColor
        return Assets.CSS.githubMarkdown.asset
            .replacingOccurrences(of: "$color-accent-fg-dark", with: dark)
            .replacingOccurrences(of: "$color-accent-fg-light", with: light)
    }

    func buildHTML() {
        self.html = Assets.HTML.proposalTemplate.asset
            .replacingOccurrences(of: "$title", with: proposal.title)
            .replacingOccurrences(of: "$githubMarkdownCss", with: githubMarkdownCss)
            .replacingOccurrences(of: "$highlightjsStyleCss", with: highlight.asset)
            .replacingOccurrences(of: "$markedJs", with: Assets.Js.marked.asset)
            .replacingOccurrences(of: "$highlightJs", with: Assets.Js.highlight.asset)
            .replacingOccurrences(of: "$highlightJsSwift", with: Assets.Js.highlightSwift.asset)
            .replacingOccurrences(of: "$markdown", with: markdown)
    }
}
