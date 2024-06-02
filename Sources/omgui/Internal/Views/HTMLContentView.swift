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
        
        let activeAddress: AddressName?
        var pendingContent: String?

        var handleURL: ((_ url: URL?) -> Void)?
        
        init(activeAddress: AddressName?, pendingContent: String? = nil, handleURL: ((_: URL?) -> Void)? = nil) {
            self.activeAddress = activeAddress
            self.pendingContent = pendingContent
            self.handleURL = handleURL
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            switch (navigationAction.navigationType, navigationAction.request.url?.host() == nil) {
            /// This... isn't a great experience.
            /// Hold onto the code until we're ready to handle these links natively
            /*
            case (.linkActivated, true):
                // Should handle natively one day
                guard let address = activeAddress, let path = navigationAction.request.url?.path(), let omgURL = URL(string: "https://\(address).omg.lol".appending(path)) else {
                    // Host is empty and path is too? Cancel that
                    return .cancel
                }
                let request = URLRequest(url: omgURL)
                Task {
                    await webView.load(request)
                }
                return .cancel
             */
            case (.linkActivated, _):
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
    
    let activeAddress: AddressName?
    let htmlContent: String?
    
    @Binding
    var activeURL: URL?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(activeAddress: activeAddress) { url in
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
            HTMLContentView(activeAddress: "preview", htmlContent: content, activeURL: $url)
                .onAppear {
                    Task {
                        let new = try await SampleData().fetchAddressProfile("some", credential: nil)
                        Self.content = new?.content ?? "Failed"
                    }
                }
        }
    }
}
