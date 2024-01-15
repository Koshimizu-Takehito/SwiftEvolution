import SwiftUI

// MARK: - NSViewRepresentable
#if os(macOS)
protocol UIViewRepresentable: NSViewRepresentable where NSViewType == ViewType {
    associatedtype ViewType: NSView

    @MainActor
    func makeUIView(context: Context) -> ViewType
    @MainActor
    func updateUIView(_ uiView: ViewType, context: Context)
}

extension UIViewRepresentable {
    @MainActor
    func makeNSView(context: Context) -> ViewType {
        makeUIView(context: context)
    }

    @MainActor
    func updateNSView(_ uiView: ViewType, context: Context) {
        updateUIView(uiView, context: context)
    }
}
#endif
