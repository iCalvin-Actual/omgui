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
            HStack(alignment: .firstTextBaseline) {
                Text(model.displayEmoji)
                    .font(.system(size: 42))
                Spacer()
                if context != .profile {
                    AddressNameView(model.address, font: .title3)
                        .foregroundColor(.black)
                        .padding([.horizontal, .bottom], 4)
                }
            }
            
            VStack(alignment: .leading) {
                Group {
                    /*
                     This was tricky to set up
                     so I'm leaving it here
                     
//                    Text(model.displayEmoji)
//                        .font(.system(size: 44))
//                    + Text(" ").font(.largeTitle) +
                     */
                    Text(model.status)
                        .font(.body)
                        .frame(maxWidth: .infinity)
                }
                .lineLimit(5)
                .multilineTextAlignment(.leading)
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
        .padding([.horizontal])
    }
}
