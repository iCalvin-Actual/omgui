//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/12/23.
//

import SwiftUI

struct DirectoryView: View {
    @EnvironmentObject
    var appModel: AppModel
    
    @ObservedObject
    var dataFetcher: AddressDirectoryDataFetcher
    
    @AppStorage("app.lol.directory.showPinned", store: .standard)
    var showPinned: Bool = true
    
    @State
    var queryString: String = ""
    @State
    var sort: Sort = .alphabet
    
    let filters: [FilterOption]
    
    var menuBuilder: ContextMenuBuilder<AddressModel>?
    
    init(dataFetcher: AddressDirectoryDataFetcher, filters: [FilterOption] = .everyone) {
        self.dataFetcher = dataFetcher
        
        self.filters = filters
        self.menuBuilder = ContextMenuBuilder()
    }
    
    var unfilteredItems: [AddressModel] {
        dataFetcher.listItems
    }
    
    var pinned: [AddressModel] {
        unfilteredItems.filter { appModel.isPinned($0.addressName) }
    }
    
    var remainder: [AddressModel] {
        unfilteredItems.filter { !appModel.isPinned($0.addressName) }
    }
    
    func filtered(_ listItems: [AddressModel]) -> [AddressModel] {
        var filters = filters
        if !queryString.isEmpty {
            filters.append(.query(queryString))
        }
        return filters
            .applyFilters(to: listItems, appModel: appModel)
            .sorted(with: sort)
    }
    
    var body: some View {
        let pinned = pinned
        List {
            if !pinned.isEmpty {
                Section(header: {
                    Text("Pinned")
                }(), content: {
                    ForEach(filtered(pinned)) { rowView($0) }
                })
                Divider()
                    .padding(.bottom, 0)
            }
            Section {
                ForEach(filtered(remainder)) { rowView($0) }
            }
        }
        .refreshable(action: {
            await dataFetcher.update()
        })
        .searchable(text: $queryString, placement: .automatic)
        .toolbar(content: {
            SortOrderMenu(sort: $sort, options: AddressModel.sortOptions)
        })
        .listStyle(.plain)
    }
    
    @ViewBuilder
    func rowView(_ item: AddressModel) -> some View {
        ZStack(alignment: .leading) {
            NavigationLink(value: NavigationDestination.address(item.addressName)) {
                EmptyView()
            }
            .opacity(0)
            
            ListRow(model: item)
        }
        .listRowSeparator(.hidden, edges: .all)
        .contextMenu(menuItems: {
            self.menuBuilder?.contextMenu(for: item, with: appModel)
        })
    }
}
