import Foundation

actor MarkdownRipository {
    let url: MarkdownURL

    init(url: MarkdownURL) {
        self.url = url
    }

    func fetch() async throws -> String {
        let (data, _) = try await URLSession.shared.data(from: url.rawValue)
        // 取得したテキストの特殊文字をエスケープしておく。
        // エスケープしないと、marked の解析に失敗する。
        return (String(data: data, encoding: .utf8) ?? "")
            .replacingOccurrences(of: "\n", with: #"\n"#)
            .replacingOccurrences(of: "'", with: #"\'"#)
    }
}
