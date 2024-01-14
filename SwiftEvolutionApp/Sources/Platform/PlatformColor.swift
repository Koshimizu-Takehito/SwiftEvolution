import SwiftUI

// MARK: - Color
#if os(macOS)
/// NSColor のエイリアス
typealias PlatformColor = NSColor
extension PlatformColor {
    static var systemBackground: PlatformColor {
        windowBackgroundColor
    }
}

extension NSView {
    var backgroundColor: PlatformColor? {
        get {
            (layer?.backgroundColor).flatMap(PlatformColor.init(cgColor:))
        }
        set {
            layer?.backgroundColor = newValue?.cgColor
        }
    }
}

#elseif os(iOS)
/// UIColor のエイリアス
typealias PlatformColor = UIColor

#else
struct PlatformColor {}

#endif
