public enum SyntaxHighlight: String, Hashable, CaseIterable, Identifiable, Sendable {
    case androidStudio = "androidstudio"
    case atomOneDark = "atom-one-dark"
    case atomOneLight = "atom-one-light"
    case monokai = "monokai"
    case nord = "nord"
    case obsidian = "obsidian"
    case rainbow = "rainbow"
    case vs2015 = "vs2015"
    case xcode = "xcode"
    case xcodeDark = "xcode-dark"

    public var id: String {
        rawValue
    }

    public var displayName: String {
        rawValue
    }
}
