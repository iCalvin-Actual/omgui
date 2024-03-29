//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/12/23.
//

import SwiftUI

struct DirectoryView: View {
    @ObservedObject
    var dataFetcher: AddressDirectoryDataFetcher
    
    @AppStorage("app.lol.directory.showPinned", store: .standard)
    var showPinned: Bool = true
    
    @EnvironmentObject
    var sceneModel: SceneModel
    
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
    
    func filtered(_ listItems: [AddressModel]) -> [AddressModel] {
        var filters = filters
        if !queryString.isEmpty {
            filters.append(.query(queryString))
        }
        return filters
            .applyFilters(to: listItems, addressBook: sceneModel.addressBook)
            .sorted(with: sort)
    }
    
    var body: some View {
        List {
            Section {
                ForEach(filtered(unfilteredItems)) { rowView($0) }
            }
        }
        .refreshable(action: {
            await dataFetcher.perform()
        })
        .searchable(text: $queryString, placement: .automatic)
        .toolbar(content: {
            SortOrderMenu(sort: $sort, options: AddressModel.sortOptions)
        })
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                ThemedTextView(text: "directory")
            }
        }
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
            self.menuBuilder?.contextMenu(for: item, sceneModel: sceneModel)
        })
    }
}
