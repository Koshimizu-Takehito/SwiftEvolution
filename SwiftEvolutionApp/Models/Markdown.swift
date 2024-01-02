import SwiftUI
import Observation

@Observable
final class Markdown {
    let proposal: Proposal
    var codeHighlight: CodeHighlight = .atomOneDark {
        didSet { buildHTML() }
    }
    private(set) var markdown = "" {
        didSet { buildHTML() }
    }
    private(set) var html: String?

    init(proposal: Proposal) {
        self.proposal = proposal
        Task { try await self.fetch() }
    }
}

private extension Markdown {
    private func fetch() async throws {
        // TODO: Host を切り替える
        let url = URL(string: "https://raw.githubusercontent.com/apple/swift-evolution/main/proposals/\(proposal.link)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        markdown = (String(data: data, encoding: .utf8) ?? "")
            .replacingOccurrences(of: "\n", with: #"\n"#)
            .replacingOccurrences(of: "'", with: #"\'"#)
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
            .replacingOccurrences(of: "$highlightjsStyleCss", with: codeHighlight.asset)
            .replacingOccurrences(of: "$markedJs", with: HTMLAsset.Js.marked.asset)
            .replacingOccurrences(of: "$highlightJs", with: HTMLAsset.Js.highlight.asset)
            .replacingOccurrences(of: "$highlightJsSwift", with: HTMLAsset.Js.highlightSwift.asset)
            .replacingOccurrences(of: "$markdown", with: markdown)
    }
}
