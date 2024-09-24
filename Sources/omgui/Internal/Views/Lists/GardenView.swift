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
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                AddressNameView(model.addressName)
                    .lineLimit(3)
                Spacer()
                if let caption = model.listCaption, !caption.isEmpty {
                    Text(caption)
                        .multilineTextAlignment(.trailing)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .truncationMode(.head)
                        .frame(alignment: .top)
                }
            }
            .padding(4)
            .padding(.horizontal, 4)
            .padding(.top, 4)
            HStack(alignment: .bottom) {
                AddressIconView(address: model.addressName, size: 55)
                
                Text(model.listSubtitle)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .fontDesign(.monospaced)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .asCard(color: cardColor, material: .regular, padding: cardPadding, radius: cardradius, selected: showSelection)
        }
        .asCard(color: cardColor, padding: 0, radius: cardradius, selected: showSelection)
    }
}
