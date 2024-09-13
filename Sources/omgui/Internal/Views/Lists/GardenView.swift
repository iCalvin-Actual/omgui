//
//  File 2.swift
//  
//
//  Created by Calvin Chestnut on 3/15/23.
//

import SwiftUI

struct GardenView: View {
    
    @ObservedObject
    var fetcher: NowGardenDataFetcher
    
    var body: some View {
        ListView<NowListing, EmptyView>(dataFetcher: fetcher)
    }
}

struct GardenItemView: View {
    let model: NowListing
    
    let cardColor: Color
    let cardPadding: CGFloat
    let cardradius: CGFloat
    let showSelection: Bool
    
    init(model: NowListing, cardColor: Color, cardPadding: CGFloat, cardradius: CGFloat, showSelection: Bool) {
        self.model = model
        self.cardColor = cardColor
        self.cardPadding = cardPadding
        self.cardradius = cardradius
        self.showSelection = showSelection
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                AddressIconView(address: model.addressName)
                Text(model.listTitle)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            let subtitle = model.listSubtitle
            let caption = model.listCaption ?? ""
            let hasMoreText: Bool = !subtitle.isEmpty || !caption.isEmpty
            if hasMoreText {
                HStack(alignment: .bottom) {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fontDesign(.monospaced)
                        .bold()
                    Spacer()
                    Text(caption)
                        .foregroundColor(.gray.opacity(0.6))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fontDesign(.rounded)
                }
            }
        }
        .foregroundStyle(Color.black)
        .asCard(color: cardColor, padding: cardPadding, radius: cardradius, selected: showSelection)
        .fontDesign(.serif)
    }
}
