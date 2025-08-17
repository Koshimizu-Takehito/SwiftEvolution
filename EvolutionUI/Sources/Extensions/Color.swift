import SwiftUI

extension Color {
    /// A platform-appropriate color that mirrors the system's dark text color.
    public static var darkText: Color {
        #if os(macOS)
            Color(NSColor.labelColor)
        #elseif os(iOS)
            Color(UIColor.label)
        #endif
    }
}
