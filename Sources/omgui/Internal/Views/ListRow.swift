//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI
import Foundation

struct ListRow<T: Listable>: View {
    @Environment(SceneModel.self)
    var sceneModel
    
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
            return 0
        case .standard:
            return 0
        }
    }
    
    var trailingPadding: CGFloat {
        verticalPadding / 2
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: verticalPadding) {
                Text(model.listTitle)
                    .font(.title3)
                    .bold()
                Spacer()
                let subtitle = model.listSubtitle
                let caption = model.listCaption ?? ""
                let hasMoreText: Bool = !subtitle.isEmpty || !caption.isEmpty
                if hasMoreText {
                    HStack(alignment: .bottom) {
                        Text(subtitle)
                            .font(.headline)
                            .foregroundColor(.black.opacity(0.8))
                            .bold()
                        Spacer()
                        Text(caption)
                            .foregroundColor(.gray.opacity(0.6))
                            .font(.subheadline)
                    }
                    .padding(.trailing, trailingPadding)
                }
            }
                
            if !model.hideIcon {
                if let icon = model.iconURL {
                    AsyncImage(url: icon) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.lolRandom(model.addressName)
                    }
                    .frame(width: 88, height: 88)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    AddressIconView(address: model.addressName)
                }
            }
        }
        .padding(.vertical, verticalPadding)
        .padding(.trailing, trailingPadding)
        .onAppear{
            sceneModel.fetchIcon(model.addressName)
        }
        .asCard(color: .lolRandom(model.listTitle), padding: 4, radius: 8)
        .fontDesign(.serif)
        .padding(2)
    }
}
