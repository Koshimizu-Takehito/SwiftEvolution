import SwiftUI

#if os(macOS) || os(tvOS)
struct NavigationBarItem {
    enum TitleDisplayMode {
        case automatic
        case inline
        case large
    }
}
#endif

extension View {
    @inline(__always)
    func iOSNavigationBarTitleDisplayMode(_ displayMode: NavigationBarItem.TitleDisplayMode) -> some View {
#if os(macOS) || os(tvOS)
        self
#else
        navigationBarTitleDisplayMode(displayMode)
#endif
    }
}
