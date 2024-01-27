import SwiftUI

struct ProposalHTMLBuilder {
    typealias HTMLColor = (dark: String, light: String)

    /// HTML 文字列を生成
    func build(markdown: Markdown, highlight: SyntaxHighlight) -> String? {
        guard let text = markdown.text else {
            return nil
        }
        let title = markdown.proposal.title
        let accent = markdown.proposal.state.accentColor
        return Assets.HTML.proposalTemplate.asset
            // HTML のタイトルを設定
            .replacingOccurrences(of: "$title", with: title)
            // github-markdown の　CSS を設定
            .replacingOccurrences(of: "$githubMarkdownCss", with: markdownCss(accent: accent))
            // シンタックスハイライトの　CSS を設定
            .replacingOccurrences(of: "$highlightjsStyleCss", with: highlight.asset)
            // marked の javascript を設定。マークダウンから HTML に変換される
            .replacingOccurrences(of: "$markedJs", with: Assets.Js.marked.asset)
            // シンタックスハイライトの　javascript を設定
            .replacingOccurrences(of: "$highlightJs", with: Assets.Js.highlight.asset)
            // シンタックスハイライトの　javascript を設定（ Swift ）
            .replacingOccurrences(of: "$highlightJsSwift", with: Assets.Js.highlightSwift.asset)
            // マークダウンを HTML ファイルに注入
            .replacingOccurrences(of: "$markdown", with: text)
    }

    /// github-markdown の　CSS
    func markdownCss(accent: HTMLColor) -> String {
        // プロポーザルに関連したレビューステータスの配色をアクセントカラーとして注入
        Assets.CSS.githubMarkdown.asset
            .replacingOccurrences(of: "$body-font-size", with: bodyFontSize)
            .replacingOccurrences(of: "$color-accent-fg-dark", with: accent.dark)
            .replacingOccurrences(of: "$color-accent-fg-light", with: accent.light)
            .replacingOccurrences(of: "$background-color-dark", with: background.dark)
            .replacingOccurrences(of: "$background-color-light", with: background.light)
    }

    /// HTML の背景色
    var background: HTMLColor {
#if os(macOS)
        return ("#313131", "#ececec") // NSColor.windowBackgroundColor
#else
        return ("#0d1117", "#ffffff")
#endif
    }

    /// 本文のフォントサイズ
    var bodyFontSize: String {
#if os(macOS)
        return "20px"
#else
        return "40px"
#endif
    }
}
