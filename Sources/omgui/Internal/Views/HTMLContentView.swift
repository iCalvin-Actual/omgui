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
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            return .allow
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
    
    let htmlContent: String?
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
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
    
    static var previews: some View {
        HTMLContentView(htmlContent: content)
            .onAppear {
                Task {
                    let new = try await SampleData().fetchAddressProfile("some")
                    Self.content = new?.content ?? "Failed"
                }
            }
    }
}
