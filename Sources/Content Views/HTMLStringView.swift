import SwiftUI
import WebKit

struct HTMLStringView: UIViewRepresentable {
    
    class NavigationDelegate: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            return .allow
        }
    }
    
    let htmlContent: String
    let navigationDelegate = NavigationDelegate()
    
    func makeUIView(context: HTMLStringView.Context) -> WKWebView {
        let view = WKWebView()
        
        view.allowsLinkPreview = true
        view.allowsBackForwardNavigationGestures = true
        view.navigationDelegate = navigationDelegate
        
        view.loadHTMLString(htmlContent, baseURL: nil)
        
        return view
    }
    
    func updateUIView(_ uiView: WKWebView, context: HTMLStringView.Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
}
