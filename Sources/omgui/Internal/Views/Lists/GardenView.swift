//
//  File 2.swift
//  
//
//  Created by Calvin Chestnut on 3/15/23.
//

import SwiftUI

struct GardenView: View {
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    @Environment(\.horizontalSizeClass)
    var sizeClass
    
    let fetcher: NowGardenDataFetcher
    
    @State
    var selected: String?
    @State
    var queryString: String = ""
    @State
    var sort: Sort = .newestFirst
    
    var menuBuilder: ContextMenuBuilder<NowListing>?
    
    var body: some View {
        ModelBackedListView<NowListing, GardenItemView, EmptyView>(dataFetcher: fetcher, rowBuilder: { GardenItemView(model: $0) })
            .toolbarRole(.editor)
    }
    
    @ViewBuilder
    var sizeAppropriateBody: some View {
        switch sizeClass {
        case .compact:
            listBody
        default:
            wideBody
        }
    }
    
    @ViewBuilder
    var wideBody: some View {
        HStack {
            listBody
                .frame(width: 330)
                .clipped()
            selectedContent
                .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    var selectedContent: some View {
        if let selected = selected {
            AddressNowView(
                fetcher: AddressNowDataFetcher(
                    name: selected,
                    interface: sceneModel.interface,
                    db: sceneModel.database
                )
            )
        } else {
            ThemedTextView(text: "select a /now page")
        }
    }
    
    @ViewBuilder
    var listBody: some View {
        ModelBackedListView<NowListing, GardenItemView, EmptyView>(dataFetcher: fetcher, rowBuilder: { GardenItemView(model: $0) })
    }
}

struct GardenItemView: View {
    var model: NowListing
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(model.listTitle)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.black)
                Spacer()
                AddressIconView(address: model.addressName)
            }
            
            let subtitle = model.listSubtitle
            let caption = model.listCaption ?? ""
            let hasMoreText: Bool = !subtitle.isEmpty || !caption.isEmpty
            if hasMoreText {
                HStack(alignment: .bottom) {
                    Text(subtitle)
                        .font(.subheadline)
                        .fontDesign(.monospaced)
                        .foregroundColor(.black.opacity(0.8))
                        .bold()
                    Spacer()
                    Text(caption)
                        .foregroundColor(.gray.opacity(0.6))
                        .font(.subheadline)
                        .fontDesign(.rounded)
                }
            }
        }
        .asCard(color: .lolRandom(model.listTitle), padding: 4, radius: 8)
        .fontDesign(.serif)
        .padding(2)
    }
}
