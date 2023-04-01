//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/28/23.
//

import SwiftUI
import Ink
import MarkupEditor
import WebKit

struct EditPageView: View {
    @EnvironmentObject
    var sceneModel: SceneModel
    
    var initialContent: String
    
    @State
    private var content: String
    
    @State
    private var newContent: String
    
    static private let parser: MarkdownParser = {
        let appendBreakpoint: ((String, Substring) -> String) = { html, markdown in
            html + "<br />"
        }
        
        let paragraph = Modifier(target: .paragraphs, closure: appendBreakpoint)
        let header = Modifier(target: .headings, closure: appendBreakpoint)
        return MarkdownParser(modifiers: [paragraph, header])
    }()
    
    init(_ content: String) {
        self.initialContent = content
        let cleanContent = content.replacingOccurrences(of: "\r\n", with: "\n\n")
        let html = Self.parser.html(from: cleanContent)
        self.content = html
        self.newContent = html
    }
    
    var body: some View {
        MarkupEditorView(markupDelegate: self, wkNavigationDelegate: EditViewNavigationDelegate(), html: $content)
            .toolbar {
                ToolbarItem {
                    Button {
                        Task {
                            let newMarkdown = HTMLToMarkdownConverter.convert(newContent)
                            if let newProfile = try? await sceneModel.fetchConstructor.interface.saveAddressProfile(sceneModel.addressBook.actingAddress, content: newMarkdown, credential: sceneModel.accountModel.authKey) {
                                self.newContent = newProfile.content
                            }
                        }
                    } label: {
                        Text("Save")
                    }

                }
            }
    }
}

extension EditPageView: MarkupDelegate {
    func markupInput(_ view: MarkupWKWebView) {
        view.getHtml { html in
            self.newContent = html ?? ""
        }
    }
}

class EditViewNavigationDelegate: NSObject, WKNavigationDelegate {
    private var javascript: String {
"""
document.body.style.backgroundColor = `red`;
"""
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        DispatchQueue.main.async {
            Task {
                webView.evaluateJavaScript(self.javascript) { (result, error) in
                    if let result = result {
                        print(result)
                    }
                }
            }
        }
        return .allow
    }
}

