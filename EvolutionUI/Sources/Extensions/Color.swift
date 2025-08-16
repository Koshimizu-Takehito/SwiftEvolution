import SwiftUI

extension Color {
    public static var darkText: Color {
        #if os(macOS)
            Color(NSColor.labelColor)
        #elseif os(iOS)
            Color(UIColor.label)
        #endif
    }
}
