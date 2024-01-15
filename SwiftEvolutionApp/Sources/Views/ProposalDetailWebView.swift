import SwiftUI
import WebKit
import SafariServices
import SwiftData

/// プロポーザルのHTMLを表示するための WebView
@MainActor
struct ProposalDetailWebView: UIViewRepresentable {
    /// 該当プロポーザルのHTML
    let html: String?
    /// 表示コンテンツで利用するシンタックスハイライト
    let highlight: SyntaxHighlight
    /// HTMLのロード状態
    @Binding var isLoaded: Bool
    /// 別プロポーザルへのリンクをタップした際のコールバックハンドラ
    var onTapLinkURL: (ProposalURL) -> Void

    public func makeUIView(context: Context) -> WKWebView {
        perform {
            let view = WKWebView()
            view.navigationDelegate = context.coordinator
            view.backgroundColor = UIColor.systemBackground
            if let html {
                DispatchQueue.main.async { [weak view] in
                    view?.loadHTMLString(html, baseURL: nil)
                }
            }
            return view
        }
    }

    public func updateUIView(_ view: WKWebView, context: Context) {
        guard let html else { return }
        DispatchQueue.main.async { [weak view] in
            if !isLoaded {
                view?.loadHTMLString(html, baseURL: nil)
            } else {
                view?.evaluateJavaScript(highlight.javascript)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(isLoaded: $isLoaded, onTap: onTapLinkURL)
    }

    private func perform<T>(action: () -> T) -> T {
        if Thread.isMainThread {
            return action()
        } else {
            return DispatchQueue.main.sync(execute: action)
        }
    }
}

extension ProposalDetailWebView {
    @MainActor
    final class Coordinator: NSObject {
        private let container = try! ModelContainer(for: Schema([ProposalObject.self]))
        private let isLoaded: Binding<Bool>
        private let onTap: (ProposalURL) -> Void

        init(isLoaded: Binding<Bool>, onTap: @escaping (ProposalURL) -> Void) {
            self.isLoaded = isLoaded
            self.onTap = onTap
        }
    }
}

@MainActor
extension ProposalDetailWebView.Coordinator: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction
    ) async -> WKNavigationActionPolicy {
        guard
            let url = navigationAction.request.url,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            url.absoluteString != "about:blank"
        else {
            return .allow
        }

        switch (components.scheme, components.host, components.path) {
        case _ where url.absoluteString == "about:blank":
            // HTML 文字列のロード
            return .allow
        case (_, "github.com", let path):
            guard let match = path.firstMatch(of: /^.+\/swift-evolution\/.*\/(\d+)-.*\.md/) else {
                break
            }
            // 別プロポーザルへのリンクを送信
            send(id: match.1, url: url)
            return .cancel
        case (nil, nil, let path):
            guard let match = path.firstMatch(of: /^(\d+)-.*\.md/) else {
                break
            }
            // 別プロポーザルへのリンクを送信
            send(id: match.1)
            return .cancel
        default:
            break
        }
        showSafariView(webView: webView, url: url)
        return .cancel
    }

    nonisolated func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Task { @MainActor in
            isLoaded.wrappedValue = true
        }
    }

    nonisolated func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    }

    func send(id: some StringProtocol, url: URL? = nil) {
        let id = "SE-\(String(id))"
        let url = url.map(MarkdownURL.init(rawValue:))
        let context = container.mainContext
        guard let proposal = ProposalObject.find(by: id, in: context) else {
            return
        }
        onTap(ProposalURL(proposal, url))
    }

    /// SFSafariViewController で Web コンテンツを表示
    @MainActor
    func showSafariView(webView: WKWebView, url: URL) {
        guard url.scheme?.contains(/^https?$/) == true else { return }
#if os(macOS)
        NSWorkspace.shared.open(url)
#elseif os(iOS)
        let controller = SFSafariViewController(url: url)
        controller.preferredControlTintColor = webView.tintColor
        webView.window?.rootViewController?.show(controller, sender: self)
#endif
    }
}
