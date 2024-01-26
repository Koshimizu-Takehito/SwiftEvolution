import SwiftUI
import Observation

actor HTMLBuilder {
    typealias HTMLColor = (dark: String, light: String)

    let markdown: String
    let title: String
    let accentColor: HTMLColor
    let highlight: SyntaxHighlight

    init(proposal: Proposal, markdown: String, highlight: SyntaxHighlight) {
        self.title = proposal.title
        self.accentColor = proposal.state.accentColor
        self.markdown = markdown
        self.highlight = highlight
    }

    /// HTML 文字列を生成
    func buildHTML() -> String {
        Assets.HTML.proposalTemplate.asset
            // HTML のタイトルを設定
            .replacingOccurrences(of: "$title", with: title)
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

    /// github-markdown の　CSS
    var githubMarkdownCss: String {
        // プロポーザルに関連したレビューステータスの配色をアクセントカラーとして注入
        return Assets.CSS.githubMarkdown.asset
            .replacingOccurrences(of: "$body-font-size", with: bodyFontSize)
            .replacingOccurrences(of: "$color-accent-fg-dark", with: accentColor.dark)
            .replacingOccurrences(of: "$color-accent-fg-light", with: accentColor.light)
            .replacingOccurrences(of: "$background-color-dark", with: backgroundColor.dark)
            .replacingOccurrences(of: "$background-color-light", with: backgroundColor.light)
    }

    /// HTML の背景色
    var backgroundColor: HTMLColor {
#if os(macOS)
        return ("#313131", "#ececec") // NSColor.windowBackgroundColor
#else
        return ("#0d1117", "#ffffff")
#endif
    }

    var bodyFontSize: String {
#if os(macOS)
        return "20px"
#else
        return "40px"
#endif
    }
}
