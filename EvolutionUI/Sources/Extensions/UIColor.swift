import SwiftUI

// MARK: - Color
#if os(macOS)
    /// NSColor のエイリアス
    typealias UIColor = NSColor
    extension UIColor {
        public static var systemBackground: UIColor {
            windowBackgroundColor.usingColorSpace(.extendedSRGB)!
        }
    }

    extension NSView {
        public var backgroundColor: UIColor? {
            get {
                (layer?.backgroundColor).flatMap(UIColor.init(cgColor:))
            }
            set {
                layer?.backgroundColor = newValue?.cgColor
            }
        }
    }
#endif
