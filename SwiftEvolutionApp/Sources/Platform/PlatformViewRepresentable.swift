import SwiftUI

// MARK: - ViewRepresentable
#if os(macOS)
protocol PlatformViewRepresentable: NSViewRepresentable where NSViewType == ViewType {
    associatedtype ViewType: NSView

    @MainActor
    func makeView(context: Context) -> ViewType
    @MainActor
    func updateView(_ uiView: ViewType, context: Context)
}

extension PlatformViewRepresentable {
    @MainActor
    func makeNSView(context: Context) -> ViewType {
        makeView(context: context)
    }

    @MainActor
    func updateNSView(_ uiView: ViewType, context: Context) {
        updateView(uiView, context: context)
    }
}
#elseif os(iOS)
protocol PlatformViewRepresentable: UIViewRepresentable where UIViewType == ViewType {
    associatedtype ViewType: UIView

    @MainActor
    func makeView(context: Context) -> ViewType
    @MainActor
    func updateView(_ uiView: ViewType, context: Context)
}

extension PlatformViewRepresentable {
    @MainActor
    func makeUIView(context: Context) -> ViewType {
        makeView(context: context)
    }

    @MainActor
    func updateUIView(_ uiView: ViewType, context: Context) {
        updateView(uiView, context: context)
    }
}
#else
protocol PlatformViewRepresentable {
    @MainActor
    func makeView(context: Context) -> ViewType
    @MainActor
    func updateView(_ uiView: ViewType, context: Context)
}
#endif
