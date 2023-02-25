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
    
    var markdownText: Text {
        if let attributed = try? AttributedString(styledMarkdown: model.status) {
            return Text(attributed)
        } else {
            return Text(model.status)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if context != .profile {
                Text(model.address.addressDisplayString)
                    .font(.title3)
                    .bold()
                    .fontDesign(.serif)
                    .padding([.horizontal, .bottom], 4)
                    .foregroundColor(.black)
            }
            
            VStack(alignment: .leading) {
                Group {
                    Text(model.displayEmoji)
                        .font(.largeTitle) 
                    + Text(" ").font(.largeTitle) +
                    markdownText
                        .font(.body)
                }
                .multilineTextAlignment(.leading)
                
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
                }
                .padding(.top, 4)
            }
//            .foregroundColor(.black)
            .padding(12)
            .background(Color.lolRandom(model.displayEmoji))
            .cornerRadius(12, antialiased: true)
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
