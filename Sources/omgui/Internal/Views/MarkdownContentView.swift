//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/7/23.
//

//import MarkdownUI
import SwiftUI

struct MarkdownContentView: View {
    let content: String?
    
    var strippingComments: String? {
        let markdownComment = try! Regex(#"(?s)\/\*.*?\*\/|\/\/.*?\n"#)
        return content?.replacing(markdownComment, with: "")
    }
    
    var body: some View {
        if let content = strippingComments {
            ScrollView {
                Text(content)
                    .padding()
            }
        }
    }
}
