import SwiftUI

// MARK: - Color
#if os(macOS)
/// NSColor のエイリアス
typealias UIColor = NSColor
extension UIColor {
    static var systemBackground: UIColor {
        windowBackgroundColor
    }
}

extension NSView {
    var backgroundColor: UIColor? {
        get {
            (layer?.backgroundColor).flatMap(UIColor.init(cgColor:))
        }
        set {
            layer?.backgroundColor = newValue?.cgColor
        }
    }
}
#endif
