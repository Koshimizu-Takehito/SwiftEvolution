/// Built-in syntax highlighting themes supported by the UI.
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

    /// Conformance to `Identifiable`.
    public var id: String {
        rawValue
    }

    /// Display name shown in the UI.
    public var displayName: String {
        rawValue
    }
}
