//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct ListView<T: Listable, V: View, H: View>: View {
    
    @EnvironmentObject
    var sceneModel: SceneModel
    
    let context: ViewContext
    let filters: [FilterOption]
    
    let allowSearch: Bool
    let allowFilter: Bool
    
    @ObservedObject
    var dataFetcher: ListDataFetcher<T>
    
    @ViewBuilder
    let rowBuilder: ((T) -> V?)
    
    @ViewBuilder
    let headerBuilder: (() -> H)?
    
    @State
    var selected: T?
    @State
    var queryString: String = ""
    @State
    var sort: Sort = T.defaultSort
    
    var menuBuilder: ContextMenuBuilder<T> = .init()
    
    init(
        context: ViewContext = .column,
        filters: [FilterOption] = .everyone,
        allowSearch: Bool = true,
        allowFilter: Bool = true,
        dataFetcher: ListDataFetcher<T>,
        rowBuilder: @escaping (T) -> V?,
        headerBuilder: (() -> H)? = nil
    ) {
        self.filters = filters
        self.allowSearch = allowSearch
        self.allowFilter = allowFilter
        self.dataFetcher = dataFetcher
        self.rowBuilder = rowBuilder
        self.context = context
        self.headerBuilder = headerBuilder
    }
    
    var items: [T] {
        var filters = filters
        if !queryString.isEmpty {
            filters.append(.query(queryString))
        }
        return filters
            .applyFilters(to: dataFetcher.listItems, addressBook: sceneModel.addressBook)
            .sorted(with: sort)
    }
    
    var body: some View {
        searchableIfNeeded
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
            .toolbar {
                let sortOptions = T.sortOptions
                if sortOptions.count > 1, dataFetcher.listItems.count > 1, allowFilter {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        SortOrderMenu(sort: $sort, options: T.sortOptions)
                    }
                }
                
                if headerBuilder == nil {
                    ToolbarItem(placement: .navigationBarLeading) {
                        ThemedTextView(text: dataFetcher.title)
                    }
                }
            }
    }
    
    @ViewBuilder
    var list: some View {
        List(selection: $selected) {
            if let headerBuilder = headerBuilder {
                Section {
                    headerBuilder()
                        .listRowSeparator(.hidden)
                }
                Section(dataFetcher.title) {
                    ForEach(items, content: rowView(_:) )
                }
            } else {
                ForEach(items, content: rowView(_:) )
            }
        }
        .refreshable(action: {
            await dataFetcher.perform()
        })
        .listStyle(.plain)
    }
    
    @ViewBuilder
    var searchableIfNeeded: some View {
        if self.allowSearch {
            list
                .searchable(text: $queryString, placement: .automatic)
        } else {
            list
        }
    }
    
    @ViewBuilder
    func rowView(_ item: T) -> some View {
        ZStack(alignment: .leading) {
            if let destination = destination(for: item) {
                NavigationLink(value: destination) {
                    EmptyView()
                }
                .opacity(0)
            }
            
            buildRow(item)
        }
        .listRowSeparator(.hidden, edges: .all)
        .contextMenu(menuItems: {
            self.menuBuilder.contextMenu(for: item, with: sceneModel.addressBook)
        })
    }
    
    private func destination(for item: T) -> NavigationDestination? {
        switch item {
        case let nowModel as NowListing:
            return .now(nowModel.owner)
        case let pasteModel as PasteModel:
            return .paste(pasteModel.addressName, title: pasteModel.name)
        case let purlModel as PURLModel:
            return .purl(purlModel.addressName, title: purlModel.value)
        case let status as StatusModel:
            return .status(status.address, id: status.id)
        default:
            if context == .column {
                return .address(item.addressName)
            }
        }
        return nil
    }
    
    @ViewBuilder
    func buildRow(_ item: T) -> some View {
        if let constructedView = rowBuilder(item) {
            constructedView
        } else {
            ListRow<T>(model: item)
        }
    }
}

