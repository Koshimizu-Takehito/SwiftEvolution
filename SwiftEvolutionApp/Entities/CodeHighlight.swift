enum CodeHighlight: String, Hashable, CaseIterable, Identifiable, StringAssetConvertible {
    case androidStudio = "androidstudio"
    case atomOneDark = "atom-one-dark"
    case atomOneLight = "atom-one-light"
    case github = "github"
    case monokai = "monokai"
    case nord = "nord"
    case obsidian = "obsidian"
    case rainbow = "rainbow"
    case solarizedDark = "solarized-dark"
    case solarizedLight = "solarized-light"
    case vs2015 = "vs2015"
    case xcode = "xcode"

    var id: String {
        rawValue
    }

    var file: String {
        "\(rawValue).min"
    }
}
