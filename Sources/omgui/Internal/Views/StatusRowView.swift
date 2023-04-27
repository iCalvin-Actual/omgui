//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import MarkdownUI
import SwiftUI

struct StatusRowView: View {
    let model: StatusModel
    let context: ViewContext
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if context != .profile {
                AddressNameView(model.address, font: .title3)
                    .padding([.horizontal, .bottom], 4)
            }
            
            VStack(alignment: .leading) {
                Group {
                    Text(model.displayEmoji)
                        .font(.largeTitle)
                    + Text(" ").font(.largeTitle) +
                    Text(model.status)
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
                    if let caption = model.listCaption {
                        Text(caption)
                            .font(.caption)
                    }
                }
                .padding(.top, 4)
            }
            .foregroundColor(.black)
            .padding(12)
            .background(Color.lolRandom(model.displayEmoji))
            .cornerRadius(12, antialiased: true)
        }
    }
}
