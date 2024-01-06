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
        return HTMLAsset.CSS.githubMarkdown.asset
            .replacingOccurrences(of: "$color-accent-fg-dark", with: dark)
            .replacingOccurrences(of: "$color-accent-fg-light", with: light)
    }

    func buildHTML() {
        self.html = HTMLAsset.HTML.proposalTemplate.asset
            .replacingOccurrences(of: "$title", with: proposal.title)
            .replacingOccurrences(of: "$githubMarkdownCss", with: githubMarkdownCss)
            .replacingOccurrences(of: "$highlightjsStyleCss", with: highlight.asset)
            .replacingOccurrences(of: "$markedJs", with: HTMLAsset.Js.marked.asset)
            .replacingOccurrences(of: "$highlightJs", with: HTMLAsset.Js.highlight.asset)
            .replacingOccurrences(of: "$highlightJsSwift", with: HTMLAsset.Js.highlightSwift.asset)
            .replacingOccurrences(of: "$markdown", with: markdown)
    }
}
