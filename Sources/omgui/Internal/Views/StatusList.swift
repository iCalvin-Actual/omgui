//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct StatusList: View {
    @ObservedObject
    var fetcher: StatusLogDataFetcher
    
    @EnvironmentObject
    var sceneModel: SceneModel
    @Environment(\.horizontalSizeClass)
    var sizeClass
    
    @State
    var queryString: String = ""
    @State
    var sort: Sort = .alphabet
    
    @State
    var selected: StatusModel?
    
    let filters: [FilterOption] = []
    
    var menuBuilder: ContextMenuBuilder<StatusModel>?
    
    let context: ViewContext
    
    var body: some View {
        sizeAppropriateView
            .toolbarRole(.editor)
    }
    
    @ViewBuilder
    var sizeAppropriateView: some View {
        switch sizeClass {
        case .compact:
            compactBody
        default:
            regularBody
        }
    }
    
    var listBody: some View {
        List(selection: $selected) {
            Section {
                ForEach(fetcher.listItems) { rowView($0) }
            }
        }
        .refreshable(action: {
            await fetcher.perform()
        })
        .searchable(text: $queryString, placement: .automatic)
        .toolbar(content: {
            SortOrderMenu(sort: $sort, options: AddressModel.sortOptions)
        })
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .toolbar {
            if sizeClass == .compact {
                ToolbarItem(placement: .navigationBarLeading) {
                    ThemedTextView(text: "omg.statuslol")
                }
            }
        }
    }
    
    @ViewBuilder
    var compactBody: some View {
        listBody
    }
    
    @ViewBuilder
    var regularBody: some View {
        HStack {
            listBody
                .frame(maxWidth: 330)
            addressBody
                .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    var addressBody: some View {
        if let selectedAddress = selected?.addressName {
            AddressSummaryView(addressSummaryFetcher: sceneModel.addressBook.addressSummary(selectedAddress), context: .profile, allowEditing: false, selectedPage: .statuslog)
        } else {
            ThemedTextView(text: "Select a Status")
        }
    }
    
    @ViewBuilder
    func rowView(_ item: StatusModel) -> some View {
        rowBuilder(item)
            .tag(item.addressName)
            .listRowSeparator(.hidden, edges: .all)
            .contextMenu(menuItems: {
                self.menuBuilder?.contextMenu(for: item, sceneModel: sceneModel)
            })
    }
    
    @ViewBuilder
    func rowBuilder(_ item: StatusModel) -> some View {
        switch sizeClass {
        case .compact:
            ZStack(alignment: .leading) {
                NavigationLink(value: NavigationDestination.address(item.addressName)) {
                    EmptyView()
                }
                .opacity(0)
                
                rowBody(status: item)
            }
        default:
            rowBody(status: item)
        }
    }
    
    @ViewBuilder
    func rowBody(status: StatusModel) -> some View {
        StatusRowView(model: status, context: context)
    }
}
