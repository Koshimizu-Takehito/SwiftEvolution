import SwiftUI

struct MarkdownURL: RawRepresentable, Codable, Hashable {
    let rawValue: URL

    init(rawValue url: URL) {
        // github.com から raw.githubusercontent.com URL に変換する
        let host = "raw.githubusercontent.com"
        var component = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        component.host = host
        component.path = component.path.replacingOccurrences(of: "/blob", with: "")
        self.rawValue = component.url!
    }

    init(link: ProposalLink) {
        var component = URLComponents()
        component.scheme = "https"
        component.host = "raw.githubusercontent.com"
        // main ブランチのプロポーザル URL
        component.path = "/apple/swift-evolution/main/proposals/\(link)"
        self.rawValue = component.url!
    }
}
