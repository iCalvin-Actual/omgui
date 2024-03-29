//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import MarkdownUI
import SwiftUI
import Ink

struct StatusRowView: View {
    let model: StatusModel
    let context: ViewContext
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if context != .profile {
                AddressNameView(model.address, font: .title3)
                    .foregroundColor(.black)
                    .padding([.horizontal, .bottom], 4)
            }
            
            VStack(alignment: .leading) {
                Group {
                    Text(model.displayEmoji)
                        .font(.system(size: 44))
                    + Text(" ").font(.largeTitle) +
                    Text(model.status)
                        .font(.body)
                }
                .multilineTextAlignment(.leading)
                
                HStack {
                    Spacer()
                }
            }
            .foregroundColor(.black)
            .asCard(color: .lolRandom(model.displayEmoji), radius: 6)
            .padding(.bottom, 4)
            
            HStack(alignment: .bottom) {
                if let text = model.link?.absoluteString {
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
        }
        .padding(.horizontal)
    }
}
