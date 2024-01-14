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
        // 取得したテキストの特殊文字をエスケープしておく。
        // エスケープしないと、marked が解析に失敗する。
        markdown = (String(data: data, encoding: .utf8) ?? "")
            .replacingOccurrences(of: "\n", with: #"\n"#)
            .replacingOccurrences(of: "'", with: #"\'"#)
        buildHTML()
    }

    /// github-markdown の　CSS
    var githubMarkdownCss: String {
        // プロポーザルに関連したレビューステータスの配色をアクセントカラーとして注入
        let (dark, light) = proposal.state.accentColor
        return Assets.CSS.githubMarkdown.asset
            .replacingOccurrences(of: "$color-accent-fg-dark", with: dark)
            .replacingOccurrences(of: "$color-accent-fg-light", with: light)
    }

    func buildHTML() {
        self.html = Assets.HTML.proposalTemplate.asset
            // HTML のタイトルを設定
            .replacingOccurrences(of: "$title", with: proposal.title)
            // github-markdown の　CSS を設定
            .replacingOccurrences(of: "$githubMarkdownCss", with: githubMarkdownCss)
            // シンタックスハイライトの　CSS を設定
            .replacingOccurrences(of: "$highlightjsStyleCss", with: highlight.asset)
            // marked の javascript を設定。マークダウンから HTML に変換される
            .replacingOccurrences(of: "$markedJs", with: Assets.Js.marked.asset)
            // シンタックスハイライトの　javascript を設定
            .replacingOccurrences(of: "$highlightJs", with: Assets.Js.highlight.asset)
            // シンタックスハイライトの　javascript を設定（ Swift ）
            .replacingOccurrences(of: "$highlightJsSwift", with: Assets.Js.highlightSwift.asset)
            // マークダウンを HTML ファイルに注入
            .replacingOccurrences(of: "$markdown", with: markdown)
    }
}
