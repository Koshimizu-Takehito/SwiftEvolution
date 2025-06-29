import SwiftUI

extension ToolbarItemPlacement {
    /// Sprit View のプライマリ側
    static var content: Self {
#if os(macOS)
        .automatic
#elseif os(iOS)
        .topBarTrailing
#endif
    }
}
