import SwiftUI

extension Color {
    static var darkText: Color {
#if os(macOS)
        Color(NSColor.labelColor)
#elseif os(iOS)
        Color(UIColor.label)
#endif
    }
}
