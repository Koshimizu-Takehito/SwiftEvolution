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

    /// Sprit View のセカンダリ側
    static func detail(for vertical: UserInterfaceSizeClass?) -> Self {
#if os(macOS)
        .automatic
#elseif os(iOS)
        switch vertical {
        case .regular:
            .bottomBar
        case .compact:
            .topBarTrailing
        default:
            .automatic
        }
#endif
    }
}
