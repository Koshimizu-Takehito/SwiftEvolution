import Foundation

/// Downloads and normalizes proposal markdown files.
public actor MarkdownRipository {
    /// Remote location of the markdown file.
    public let url: MarkdownURL

    public init(url: MarkdownURL) {
        self.url = url
    }

    /// Fetches the markdown text from GitHub and escapes characters that would
    /// otherwise break downstream parsing.
    /// - Returns: The normalized markdown string.
    public func fetch() async throws -> String {
        let (data, _) = try await URLSession.shared.data(from: url.rawValue)
        // Escape special characters. Unescaped content causes failures in the
        // JavaScript `marked` parser used elsewhere in the app.
        return (String(data: data, encoding: .utf8) ?? "")
            .replacingOccurrences(of: "\n", with: #"\n"#)
            .replacingOccurrences(of: "'", with: #"\'"#)
    }
}
