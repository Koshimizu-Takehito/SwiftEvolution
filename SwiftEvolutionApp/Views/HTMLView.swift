import SwiftUI
import WebKit
import SafariServices

@MainActor
struct HTMLView: UIViewRepresentable {
    let html: String?
    let codeHighlight: CodeHighlight
    @Binding var isLoaded: Bool
    var linkID: (Proposal.ID) -> Void = { _ in }

    public func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.navigationDelegate = context.coordinator
        view.backgroundColor = UIColor.systemBackground
        if let html {
            DispatchQueue.main.async { view.loadHTMLString(html, baseURL: nil) }
        }
        return view
    }

    public func updateUIView(_ view: WKWebView, context: Context) {
        guard let html else { return }
        DispatchQueue.main.async {
            if !isLoaded {
                view.loadHTMLString(html, baseURL: nil)
            } else {
                view.evaluateJavaScript(codeHighlight.javascript)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            isLoaded: { isLoaded = $0 },
            linkID: linkID
        )
    }
}

extension HTMLView {
    @MainActor
    final class Coordinator: NSObject {
        var isLoaded: (Bool) -> Void
        var linkID: (Proposal.ID) -> Void

        init(
            isLoaded: @escaping (Bool) -> Void = { _ in },
            linkID: @escaping (Proposal.ID) -> Void = { _ in }
        ) {
            self.isLoaded = isLoaded
            self.linkID = linkID
        }
    }
}

extension HTMLView.Coordinator: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction
    ) async -> WKNavigationActionPolicy {
        // https://github.com/apple/swift-evolution/blob/main/proposals/0249-key-path-literal-function-expressions.md
        // 0418-inferring-sendable-for-methods.md
        // https://github.com/apple/swift/pull/68793
        // about:blank%23isolation-region-dataflow // SE-0414
        // https://github.com/apple/swift-evolution/blob/main/proposals/0302-concurrent-value-and-concurrent-closures.md#key-path-literals  // SE-0418
        guard
            let url = navigationAction.request.url,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            return .allow
        }

        switch (components.scheme, components.host, components.path) {
        case _ where url.absoluteString == "about:blank":
            // HTML 文字列のロード
            return webView.title == "" ? .allow: .cancel
        case (_, "github.com", let path):
            guard let match = path.firstMatch(of: /^.+\/swift-evolution\/.*\/(\d+)-.*\.md/) else { break }
            // 別プロポーザルへのリンクとして判定
            linkID("SE-\(String(match.1))")
            return .cancel
        case (nil, nil, let path):
            guard let match = path.firstMatch(of: /^(\d+)-.*\.md/) else { break }
            // 別プロポーザルへのリンクとして判定
            linkID("SE-\(String(match.1))")
            return .cancel
        default:
            break
        }
        Task { @MainActor in
            guard url.scheme?.contains(/^https?$/) == true else { return }
            print(#function, #line, url)
            let controller = SFSafariViewController(url: url)
            controller.preferredControlTintColor = webView.tintColor
            webView.window?.rootViewController?.show(controller, sender: self)
        }
        return .cancel
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
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
