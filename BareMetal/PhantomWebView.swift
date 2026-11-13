import SwiftUI
import WebKit

/// Holds the room's web view so the shell can reload it and track reachability.
/// The web view uses the default (persistent) website data store, so the room's
/// session cookie and storage live in the app's own container — they survive
/// launches, force-quits and updates, unlike the PWA whose storage iOS evicts.
final class PhantomWebStore: ObservableObject {
    @Published var failed = false
    weak var webView: WKWebView?
    private var triedFallback = false

    private static let primaryURL = URL(string: "http://oks-a17:3000/")
    private static let fallbackURL = URL(string: "http://100.77.206.103:3000/")

    func loadPrimary() {
        triedFallback = false
        if let url = Self.primaryURL {
            webView?.load(URLRequest(url: url))
        }
    }

    func reload() {
        if failed {
            failed = false
            loadPrimary()
        } else {
            webView?.reload()
        }
    }

    func navigationFailed() {
        if !triedFallback {
            triedFallback = true
            if let url = Self.fallbackURL {
                webView?.load(URLRequest(url: url))
                return
            }
        }
        failed = true
    }
}

struct PhantomWebView: UIViewRepresentable {
    @ObservedObject var store: PhantomWebStore

    func makeCoordinator() -> Coordinator { Coordinator(store: store) }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        config.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        store.webView = webView
        store.loadPrimary()
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        let store: PhantomWebStore
        init(store: PhantomWebStore) { self.store = store }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async { self.store.failed = false }
        }
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async { self.store.navigationFailed() }
        }
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async { self.store.navigationFailed() }
        }
    }
}
