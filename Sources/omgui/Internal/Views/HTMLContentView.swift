//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import SwiftUI
import Foundation
import WebKit

struct HTMLContentView: UIViewRepresentable {
    class Coordinator: NSObject, WKNavigationDelegate {
    
        var pendingContent: String?

        var handleURL: ((_ url: URL?) -> Void)?
        
        init(pendingContent: String? = nil, handleURL: ((_: URL?) -> Void)? = nil) {
            self.pendingContent = pendingContent
            self.handleURL = handleURL
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            switch navigationAction.navigationType {
            case .linkActivated:
                handleURL?(navigationAction.request.url)
                return .cancel
            default:
                return .allow
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            showPendingContentIfNeeded(in: webView)
        }
        
        func showContent(_ newContent: String?, in webView: WKWebView) {
            webView.navigationDelegate = self
            if webView.isLoading {
                pendingContent = newContent
            } else if let newContent = newContent {
                webView.loadHTMLString(newContent, baseURL: nil)
            }
        }
        
        private func showPendingContentIfNeeded(in webView: WKWebView) {
            if let pending = pendingContent {
                pendingContent = nil
                webView.loadHTMLString(pending, baseURL: nil)
            }
        }
    }
    
    @Binding
    var activeURL: URL?
    
    let htmlContent: String?
    
    func makeCoordinator() -> Coordinator {
        Coordinator { url in
            activeURL = url
        }
    }
    
    func makeUIView(context: HTMLContentView.Context) -> WKWebView {
        let view = WKWebView()
        
        view.allowsLinkPreview = true
        view.allowsBackForwardNavigationGestures = true
        
        return view
    }
    
    func updateUIView(_ uiView: WKWebView, context: HTMLContentView.Context) {
        context.coordinator.showContent(htmlContent, in: uiView)
    }
}

struct HTMLContentView_Previews: PreviewProvider {
    @State
    static var content: String = ""
    @State
    static var url: URL?
    
    static var previews: some View {
        TabView {
            HTMLContentView(activeURL: $url, htmlContent: content)
                .onAppear {
                    Task {
                        let new = try await SampleData().fetchAddressProfile("some", credential: nil)
                        Self.content = new?.content ?? "Failed"
                    }
                }
        }
    }
}
