//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/7/23.
//

import MarkdownUI
import SwiftUI

@MainActor
protocol MarkdownSourceProvider {
    var address: String { get }
    var updated: Date? { get }
}

@MainActor
struct MarkdownContentView: View {
    
    let source: MarkdownSourceProvider?
    let content: String?
    
    init(source: MarkdownSourceProvider? = nil, content: String?) {
        var strippingComments: String? {
            let markdownCommentBlock = try! Regex(#"(?s)\/\*.*?\*\/(\r\n)|(\/\/\s).*?\r\n|(---\s).*?(\s---)(\r\n)"#)
            var avatarURL: String {
                guard let address = source?.address else {
                    return "!(Profile Photo)[]"
                }
                return "![profile picture](https://profiles.cache.lol/\(address)/picture)"
            }
            var displayAddress: String {
                source?.address ?? "my address"
            }
            var lastUpdated: String {
                guard let date = source?.updated else {
                    return ""
                }
                let dateString = DateFormatter.short.string(from: date)
                return "Last updated \(dateString)"
            }
            let basicsReplaced: String? = content?
                .replacing("{profile-picture}", with: avatarURL)
                .replacing("{address}", with: displayAddress)
                .replacing("{last-updated}", with: lastUpdated)
            
            return basicsReplaced?
                .replacing(markdownCommentBlock, with: "")
        }
        self.source = source
        self.content = strippingComments
    }
    
    var body: some View {
        ScrollView {
            if let content {
                Markdown(content)
                    .padding()
            }
        }
    }
}

extension AddressNowDataFetcher: MarkdownSourceProvider {
    var address: String {
        addressName
    }
}
