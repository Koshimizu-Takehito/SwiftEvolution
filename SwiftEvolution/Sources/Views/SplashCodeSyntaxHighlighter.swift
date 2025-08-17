import MarkdownUI
import Splash
import SwiftUI

extension CodeSyntaxHighlighter where Self == SplashCodeSyntaxHighlighter {
    static func splash(theme: Splash.Theme) -> Self {
        Self.init(theme: theme)
    }
}

struct SplashCodeSyntaxHighlighter: CodeSyntaxHighlighter {
    private let highlighter: SyntaxHighlighter<Format>

    init(theme: Splash.Theme) {
        highlighter = SyntaxHighlighter(format: Format(theme: theme))
    }

    func highlightCode(_ content: String, language: String?) -> Text {
        highlighter.highlight(content)
    }
}

extension SplashCodeSyntaxHighlighter {
    private struct Format: Splash.OutputFormat {
        private let theme: Splash.Theme

        init(theme: Splash.Theme) {
            self.theme = theme
        }

        func makeBuilder() -> Builder {
            Builder(theme: theme)
        }
    }

    private struct Builder: OutputBuilder {
        private let theme: Splash.Theme
        private var string: AttributedString

        fileprivate init(theme: Splash.Theme) {
            self.theme = theme
            self.string = .init()
        }

        mutating func addToken(_ token: String, ofType type: TokenType) {
            var part = AttributedString(token)
            part.foregroundColor = theme.tokenColors[type] ?? theme.plainTextColor
            string += part
        }

        mutating func addPlainText(_ text: String) {
            var part = AttributedString(text)
            part.foregroundColor = theme.plainTextColor
            string += part
        }

        mutating func addWhitespace(_ whitespace: String) {
            string += AttributedString(whitespace)
        }

        func build() -> Text {
            Text(string)
        }
    }
}
