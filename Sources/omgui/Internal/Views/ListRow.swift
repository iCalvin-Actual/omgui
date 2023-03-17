//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI
import Foundation

struct ListRow<T: Listable>: View {
    
    let model: T
    
    @Environment(\.isSearching) var isSearching
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            
            Text(model.listTitle)
                .font(.title)
                .bold()
                .foregroundColor(.black)
                .padding(.vertical, 8)
                .padding(.bottom, 16)
                .padding(.trailing, 4)
            
            
            let subtitle = model.listSubtitle
            let caption = model.listCaption ?? ""
            let hasMoreText: Bool = !subtitle.isEmpty || !caption.isEmpty
            HStack(alignment: .bottom) {
                if hasMoreText {
                    Text(subtitle)
                        .font(.headline)
                        .foregroundColor(.accentColor.opacity(0.8))
                        .bold()
                    Spacer()
                    Text(caption)
                        .foregroundColor(.accentColor.opacity(0.6))
                        .font(.subheadline)
                } else {
                    Spacer()
                }
            }
            .padding(.trailing)
        }
        .padding(.vertical)
        .padding(.leading, 32)
        .background(Color.lolRandom(model))
        .cornerRadius(24)
        .fontDesign(.serif)
    }
}
