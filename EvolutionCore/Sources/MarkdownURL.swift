import Foundation

public struct MarkdownURL: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: URL

    public init(rawValue url: URL) {
        // github.com から raw.githubusercontent.com URL に変換する
        let host = "raw.githubusercontent.com"
        var component = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        component.host = host
        component.path = component.path.replacingOccurrences(of: "/blob", with: "")
        self.rawValue = component.url!
    }

    public init(link: String) {
        var component = URLComponents()
        component.scheme = "https"
        component.host = "raw.githubusercontent.com"
        // main ブランチのプロポーザル URL
        component.path = "/apple/swift-evolution/main/proposals/\(link)"
        self.rawValue = component.url!
    }
}
