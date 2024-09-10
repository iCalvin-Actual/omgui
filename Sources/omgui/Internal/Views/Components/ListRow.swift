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
    
    var selected: Binding<T?>
    
    var cardColor: Color {
        .lolRandom(model.listTitle)
    }
    var cardPadding: CGFloat {
        4
    }
    var cardradius: CGFloat {
        2
    }
    var showSelection: Bool {
        selected.wrappedValue == model
    }
    
    var activeStyle: Style {
        switch isSearching {
        case true:
            return .minimal
        case false:
            return preferredStyle
        }
    }
    
    init(model: T, selected: Binding<T?> = .constant(nil), preferredStyle: Style = .standard) {
        self.model = model
        self.selected = selected
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
        appropriateBody
            .fontDesign(.serif)
            .padding(2)
    }
    
    @ViewBuilder
    var appropriateBody: some View {
        if let statusModel = model as? StatusModel {
            statusBody(statusModel)
        } else if let nowModel = model as? NowListing {
            gardenView(nowModel)
        } else {
            standardBody
                .asCard(color: cardColor, padding: cardPadding, radius: cardradius, selected: showSelection)
        }
    }
    
    @ViewBuilder
    func statusBody(_ model: StatusModel) -> some View {
        StatusRowView(model: model, cardColor: cardColor, cardPadding: cardPadding, cardradius: cardradius, showSelection: showSelection)
    }
    
    @ViewBuilder
    func gardenView(_ model: NowListing) -> some View {
        GardenItemView(model: model)
    }
    
    @ViewBuilder
    func pasteView(_ model: PasteModel) -> some View {
        PasteRowView(model: model)
    }
    
    @ViewBuilder
    func purlView(_ model: PURLModel) -> some View {
        PURLRowView(model: model)
    }
    
    @ViewBuilder
    var standardBody: some View {
        VStack(alignment: .leading, spacing: verticalPadding) {
            HStack {
                if let icon = model.iconURL {
                    AsyncImage(url: icon) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.lolRandom(model.addressName)
                    }
                    .frame(width: 55, height: 55)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else if !model.hideIcon {
                    AddressIconView(address: model.addressName)
//                        .padding(2)
                }
                Spacer()
                Text(model.listTitle)
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, verticalPadding)
            .padding(.trailing, trailingPadding)
            
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
    }
}

#Preview {
    VStack {
        ListRow(model: AddressModel.sample(with: "calvin"))
        ListRow(model: StatusModel.sample(with: "calvin"))
        ListRow(model: PURLModel.sample(with: "calvin"))
        ListRow(model: PasteModel.sample(with: "calvin"))
        ListRow(model: NowListing.sample(with: "calvin"))
    }
    .padding(.horizontal)
    .environment(SceneModel.sample)
}
