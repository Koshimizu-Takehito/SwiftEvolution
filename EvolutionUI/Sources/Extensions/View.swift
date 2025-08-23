import SwiftUI

#if os(macOS) || os(tvOS)
    public struct NavigationBarItem {
        public enum TitleDisplayMode {
            case automatic
            case inline
            case large
        }
    }
#endif

extension View {
    @inline(__always)
    public func iOSNavigationBarTitleDisplayMode(_ displayMode: NavigationBarItem.TitleDisplayMode)
        -> some View
    {
        #if os(macOS) || os(tvOS)
            self
        #else
            navigationBarTitleDisplayMode(displayMode)
        #endif
    }
}
