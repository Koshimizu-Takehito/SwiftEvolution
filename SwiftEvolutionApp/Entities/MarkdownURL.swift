import SwiftUI

struct MarkdownURL: RawRepresentable, Hashable {
    var rawValue: URL

    init(rawValue url: URL) {
        // github.com から raw.githubusercontent.com URL に変換する
        let host = "raw.githubusercontent.com"
        var component = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        component.host = host
        component.path = component.path.replacingOccurrences(of: "/blob", with: "")
        self.rawValue = component.url!
    }

    init(proposal: Proposal) {
        var component = URLComponents()
        component.scheme = "https"
        component.host = "raw.githubusercontent.com"
        // main ブランチのプロポーザル URL
        component.path = "/apple/swift-evolution/main/proposals/\(proposal.link)"
        self.rawValue = component.url!
    }
}
