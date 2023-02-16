import SwiftUI
import WebKit

struct HTMLStringView: UIViewRepresentable {
    
    class NavigationDelegate: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            guard navigationAction.navigationType != .linkActivated else {
                return .cancel
            }
            return .allow
        }        
    }
    
    let htmlContent: String
    let navigationDelegate = NavigationDelegate()
    
    func makeUIView(context: HTMLStringView.Context) -> WKWebView {
        let view = WKWebView()
        
        view.allowsLinkPreview = true
        view.allowsBackForwardNavigationGestures = false
        view.navigationDelegate = navigationDelegate
        
        return view
    }
    
    func updateUIView(_ uiView: WKWebView, context: HTMLStringView.Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
}
