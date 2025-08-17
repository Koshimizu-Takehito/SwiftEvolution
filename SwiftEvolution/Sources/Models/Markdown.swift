import SwiftUI
import Observation

/// マークダウン
struct Markdown: Codable, Hashable, Identifiable {
    /// マークダウンの一意識別子
    ///
    /// 同一のプロポーザルだとしても異なるブランチやリポジトリの可能性があるので、
    /// `URL` を一意識別子とする。
    var id: URL { url.rawValue }
    /// 該当のプロポーザル
    let proposal: Proposal
    /// プロポーザルのURL
    let url: MarkdownURL
    /// マークダウン文字列
    var text: String?

    init(proposal: Proposal, url: MarkdownURL? = nil) {
        self.proposal = proposal
        self.url = url ?? MarkdownURL(link: proposal.link)
    }

    func fetch() async throws -> String {
        try await MarkdownRipository(url: url).fetch()
            .replacingOccurrences(of: "\\n", with: "\n")
    }
}
