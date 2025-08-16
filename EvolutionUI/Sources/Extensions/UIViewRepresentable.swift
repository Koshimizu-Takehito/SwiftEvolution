import SwiftUI

// MARK: - NSViewRepresentable
#if os(macOS)
    public protocol UIViewRepresentable: NSViewRepresentable where NSViewType == ViewType {
        associatedtype ViewType: NSView
        @MainActor
        public func makeUIView(context: Context) -> ViewType
        @MainActor
        public func updateUIView(_ uiView: ViewType, context: Context)
    }

    extension UIViewRepresentable {
        @MainActor
        public func makeNSView(context: Context) -> ViewType {
            makeUIView(context: context)
        }

        @MainActor
        public func updateNSView(_ uiView: ViewType, context: Context) {
            updateUIView(uiView, context: context)
        }
    }
#endif
