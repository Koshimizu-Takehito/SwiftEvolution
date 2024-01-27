import SwiftUI

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
