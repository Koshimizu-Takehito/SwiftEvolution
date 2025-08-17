import Foundation

/// Represents the markdown content for a proposal.
public struct Markdown: Codable, Hashable, Identifiable, Sendable {
    /// Unique identifier for the markdown document.
    ///
    /// Even if two proposals share the same identifier, they may live on
    /// different branches or repositories, so the full ``URL`` is used as
    /// the identifier.
    public var id: URL { url.rawValue }
    /// The proposal associated with this markdown document.
    public let proposal: Proposal
    /// The remote URL pointing to the markdown file.
    public let url: MarkdownURL
    /// Raw markdown text, populated after ``fetch()`` is called.
    public var text: String?

    /// Creates a new markdown container for the given proposal.
    /// - Parameters:
    ///   - proposal: The proposal that owns the markdown content.
    ///   - url: Optional explicit URL if it differs from the proposal's link.
    public init(proposal: Proposal, url: MarkdownURL? = nil) {
        self.proposal = proposal
        self.url = url ?? MarkdownURL(link: proposal.link)
    }

    /// Retrieves the markdown text from GitHub.
    /// - Returns: The file contents as a normalized string.
    public func fetch() async throws -> String {
        try await MarkdownRipository(url: url).fetch()
            .replacingOccurrences(of: "\\n", with: "\n")
    }
}
