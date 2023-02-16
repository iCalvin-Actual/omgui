//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 2/9/23.
//

import SwiftUI
import Foundation

@available(iOS 16.1, *)
struct StatusView: View {
    let model: StatusModel
    let context: Context
    
    @Environment(\.isSearching) var isSearching
    
    var narrow: Bool {
        isSearching
    }
    
    init(model: StatusModel, context: Context) {
        self.model = model
        self.context = context
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if context != .profile {
                Text("@\(model.address)")
                    .font(.title3)
                    .padding(2)
            }
            
            HStack(alignment: .top) {
                Text(model.displayEmoji)
                    .font(.largeTitle)
                    .aspectRatio(1.0, contentMode: .fit)
                    .padding()
                
                VStack(alignment: .leading, spacing: 8) {
                    MarkdownTextView(model.status)
                        .font(.body)
                    
                    HStack(alignment: .bottom) {
                        if let text = model.linkText {
                            Button(action: {
                                print("Show Link")
                            }, label: {
                                Label(text, systemImage: "link")
                            })
                        }
                        Spacer()
                        Text(model.subtitle)
                            .font(.caption)
                            .foregroundColor(Color(uiColor: .lightGray))
                    }
                }
                .padding([.vertical, .trailing])
            }
            .multilineTextAlignment(.leading)
            .accentColor(.primary)
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(8, antialiased: true)
        }
    }
}

extension StatusModel {
    var displayEmoji: String {
        emoji ?? "✨"
    }
    
    var subtitle: String {
        DateFormatter.short.string(from: posted)
    }
}
