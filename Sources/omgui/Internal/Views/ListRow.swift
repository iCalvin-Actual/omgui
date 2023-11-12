//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI
import Foundation

struct ListRow<T: Listable>: View {
    
    enum Style {
        case standard
        case smaller
        case minimal
    }
    
    let model: T
    
    var preferredStyle: Style
    
    var activeStyle: Style {
        switch isSearching {
        case true:
            return .minimal
        case false:
            return preferredStyle
        }
    }
    
    init(model: T, preferredStyle: Style = .standard) {
        self.model = model
        self.preferredStyle = preferredStyle
    }
    
    @Environment(\.isSearching) var isSearching
    
    var verticalPadding: CGFloat {
        switch activeStyle {
        case .minimal:
            return 0
        case .smaller:
            return 4
        case .standard:
            return 8
        }
    }
    
    var trailingPadding: CGFloat {
        verticalPadding / 2
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(model.listTitle)
                .font(.title)
                .bold()
                .foregroundColor(.black)
                .padding(.vertical, verticalPadding)
                .padding(.trailing, trailingPadding)
            
            
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
        .padding(4)
        .asCard(color: .lolRandom(model), radius: 8)
        .fontDesign(.serif)
    }
}
