import SwiftUI

// MARK: - Assets
enum Assets {
    enum CSS: String, StringAssetConvertible {
        case githubMarkdown = "github-markdown"
        case highlightjsAtomOneDark = "atom-one-dark.min"
    }

    enum Js: String, StringAssetConvertible {
        case marked = "marked.min"
        case highlight = "highlight.min"
        case highlightSwift = "highlightjs.swift.min"
    }

    enum HTML: String, StringAssetConvertible {
        case proposalTemplate = "proposal.template"
    }
}

// MARK: - StringAssetConvertible
protocol StringAssetConvertible {
    var asset: String { get }
}

extension StringAssetConvertible where Self: RawRepresentable, RawValue == String {
    var asset: String {
        String(data: NSDataAsset(name: rawValue)!.data, encoding: .utf8)!
    }
}
