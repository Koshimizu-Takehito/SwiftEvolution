import SwiftUI

// MARK: - Color
#if os(macOS)
    /// NSColor のエイリアス
public typealias UIColor = NSColor
    extension UIColor {
        static var tintColor: UIColor {
            controlTextColor.usingColorSpace(.extendedSRGB)!
        }

        public static var systemBackground: UIColor {
            windowBackgroundColor.usingColorSpace(.extendedSRGB)!
        }

        public static var secondarySystemBackground: UIColor {
            windowBackgroundColor.usingColorSpace(.extendedSRGB)!
        }

        public static var label: UIColor {
            labelColor.usingColorSpace(.extendedSRGB)!
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
