import SwiftUI

enum CodeHighlight: String, Hashable, CaseIterable, Identifiable {
    case androidStudio = "androidstudio"
    case atomOneDark = "atom-one-dark"
    case atomOneLight = "atom-one-light"
    case monokai = "monokai"
    case nord = "nord"
    case obsidian = "obsidian"
    case rainbow = "rainbow"
    case vs2015 = "vs2015"
    case xcode = "xcode"

    static var current: Self {
        get {
            let defaults = UserDefaults.standard
            let string = defaults.string(forKey: String(describing: Self.self))
            return string.flatMap(CodeHighlight.init) ?? .atomOneDark
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue.rawValue, forKey: String(describing: Self.self))
        }
    }

    var id: String {
        rawValue
    }

    var displayName: String {
        rawValue
    }

    var file: String {
        "\(rawValue).min"
    }

    var asset: String {
        String(data: NSDataAsset(name: file)!.data, encoding: .utf8)!
    }

    var javascript: String {
        "document.getElementById('highlight_css').innerHTML = '\(asset)';"
    }
}
