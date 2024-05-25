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
    @Environment(\.horizontalSizeClass)
    var sizeClass
    
    @State
    var queryString: String = ""
    @State
    var sort: Sort = .alphabet
    
    @State
    var selected: String?
    
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
        sizeAppropriateView
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
    
    @ViewBuilder
    var listBody: some View {
        List(selection: $selected) {
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
            if sizeClass == .compact {
                ToolbarItem(placement: .navigationBarLeading) {
                    ThemedTextView(text: "directory")
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
        if let selectedAddress = selected {
            AddressSummaryView(addressSummaryFetcher: sceneModel.addressBook.addressSummary(selectedAddress), context: .profile, allowEditing: false, selectedPage: .profile)
        } else {
            Text("Select an Address")
        }
    }
    
    @ViewBuilder
    func rowView(_ item: AddressModel) -> some View {
        rowBuilder(item)
            .tag(item.addressName)
            .listRowSeparator(.hidden, edges: .all)
            .contextMenu(menuItems: {
                self.menuBuilder?.contextMenu(for: item, sceneModel: sceneModel)
            })
    }
    
    @ViewBuilder
    func rowBuilder(_ item: AddressModel) -> some View {
        switch sizeClass {
        case .compact:
            ZStack(alignment: .leading) {
                NavigationLink(value: NavigationDestination.address(item.addressName)) {
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
