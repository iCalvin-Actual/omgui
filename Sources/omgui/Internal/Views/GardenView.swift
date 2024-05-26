//
//  File 2.swift
//  
//
//  Created by Calvin Chestnut on 3/15/23.
//

import SwiftUI

struct GardenView: View {
    @EnvironmentObject
    var sceneModel: SceneModel
    @Environment(\.horizontalSizeClass)
    var sizeClass
    
    @ObservedObject
    var fetcher: NowGardenDataFetcher
    
    @State
    var selected: String?
    @State
    var queryString: String = ""
    @State
    var sort: Sort = .newestFirst
    
    var menuBuilder: ContextMenuBuilder<NowListing>?
    
    var body: some View {
        sizeAppropriateBody
            .toolbarRole(.editor)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ThemedTextView(text: "now.garden 🌷")
                }
            }
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
            AddressNowView(fetcher: sceneModel.addressBook.fetchConstructor.addresNowFetcher(selected))
        } else {
            ThemedTextView(text: "Select a Now page")
        }
    }
    
    @ViewBuilder
    var listBody: some View {
        List(selection: $selected) {
            ForEach(fetcher.listItems, content: rowView(_:))
        }
        .refreshable(action: {
            await fetcher.perform()
        })
        .searchable(text: $queryString, placement: .automatic)
        .toolbar(content: {
            SortOrderMenu(sort: $sort, options: AddressModel.sortOptions)
        })
        .listStyle(.plain)
    }
    
    @ViewBuilder
    func rowView(_ item: NowListing) -> some View {
        rowBuilder(item)
            .tag(item.addressName)
            .listRowSeparator(.hidden, edges: .all)
            .contextMenu(menuItems: {
                self.menuBuilder?.contextMenu(for: item, sceneModel: sceneModel)
            })
    }
    
    @ViewBuilder
    func rowBuilder(_ item: NowListing) -> some View {
        switch sizeClass {
        case .compact:
            ZStack(alignment: .leading) {
                NavigationLink(value: NavigationDestination.now(item.addressName)) {
                    EmptyView()
                }
                .opacity(0)
                
                ListRow(model: item)
            }
        default:
            ListRow(model: item)
        }
    }
}
