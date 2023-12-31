import SwiftUI
import WebKit

struct HTMLView: UIViewRepresentable {
    let html: String?
    @Binding var isLoaded: Bool

    public func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView(frame: .init(origin: .zero, size: .init(width: 200, height: 200)))
        view.navigationDelegate = context.coordinator
        view.backgroundColor = UIColor.systemBackground
        if let html {
            view.loadHTMLString(html, baseURL: nil)
        }
        return view
    }

    public func updateUIView(_ view: WKWebView, context: Context) {
        guard let html else {
            return
        }
        view.loadHTMLString(html, baseURL: nil)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator { isLoaded in
            self.isLoaded = isLoaded
        }
    }
}

extension HTMLView {
    final class Coordinator: NSObject, WKNavigationDelegate {
        var isLoaded: (Bool) -> Void

        init(isLoaded: @escaping (Bool) -> Void) {
            self.isLoaded = isLoaded
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if !webView.canGoBack {
                isLoaded(true)
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            if !webView.canGoBack {
                isLoaded(false)
            }
        }
    }
}
