import Foundation

/// マークダウン
public struct Markdown: Codable, Hashable, Identifiable, Sendable {
    /// マークダウンの一意識別子
    ///
    /// 同一のプロポーザルだとしても異なるブランチやリポジトリの可能性があるので、
    /// `URL` を一意識別子とする。
    public var id: URL { url.rawValue }
    /// 該当のプロポーザル
    public let proposal: Proposal
    /// プロポーザルのURL
    public let url: MarkdownURL
    /// マークダウン文字列
    public var text: String?

    public init(proposal: Proposal, url: MarkdownURL? = nil) {
        self.proposal = proposal
        self.url = url ?? MarkdownURL(link: proposal.link)
    }

    public func fetch() async throws -> String {
        try await MarkdownRipository(url: url).fetch()
            .replacingOccurrences(of: "\\n", with: "\n")
    }
}
