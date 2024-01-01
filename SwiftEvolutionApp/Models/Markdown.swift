import SwiftUI
import Observation

@Observable
final class Markdown {
    let proposal: Proposal
    private(set) var markdown = ""
    private(set) var html: String?

    init(proposal: Proposal) {
        self.proposal = proposal
        Task { try await self.fetch() }
    }

    func fetch() async throws {
        let url = URL(string: "https://raw.githubusercontent.com/apple/swift-evolution/main/proposals/\(proposal.link)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        self.markdown = (String(data: data, encoding: .utf8) ?? "")
            .replacingOccurrences(of: "\n", with: #"\n"#)
            .replacingOccurrences(of: "'", with: #"\'"#)
        self.html = buildHTML()
    }
}

private extension Markdown {
    var githubMarkdownCss: String {
        let (dark, light) = proposal.state.accentColor
        return String(data: NSDataAsset(name: "github-markdown")!.data, encoding: .utf8)!
            .replacingOccurrences(of: "$color-accent-fg-dark", with: dark)
            .replacingOccurrences(of: "$color-accent-fg-light", with: light)
    }

    var markedJs: String {
        String(data: NSDataAsset(name: "marked.min")!.data, encoding: .utf8)!
    }

    var highlightJs: String {
        String(data: NSDataAsset(name: "highlight.min")!.data, encoding: .utf8)!
    }

    var proposalTemplateHTML: String {
        String(data: NSDataAsset(name: "proposal.template")!.data, encoding: .utf8)!
    }

    func buildHTML() -> String {
        proposalTemplateHTML
            .replacingOccurrences(of: "$title", with: proposal.title)
            .replacingOccurrences(of: "$githubMarkdownCss", with: githubMarkdownCss)
            .replacingOccurrences(of: "$markedJs", with: markedJs)
            .replacingOccurrences(of: "$highlightJs", with: highlightJs)
            .replacingOccurrences(of: "$markdown", with: markdown)
    }
}
