//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct ListView<T: Listable, V: View>: View {
    
    @EnvironmentObject
    var appModel: AppModel
    
    let context: ViewContext
    let filters: [FilterOption]
    
    @ObservedObject
    var dataFetcher: ListDataFetcher<T>
    
    @ViewBuilder
    let rowBuilder: ((T) -> V?)
    
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
        dataFetcher: ListDataFetcher<T>,
        rowBuilder: @escaping (T) -> V?
    ) {
        self.filters = filters
        self.dataFetcher = dataFetcher
        self.rowBuilder = rowBuilder
        self.context = context
    }
    
    var items: [T] {
        var filters = filters
        if !queryString.isEmpty {
            filters.append(.query(queryString))
        }
        return filters
            .applyFilters(to: dataFetcher.listItems, appModel: appModel)
            .sorted(with: sort)
    }
    
    var body: some View {
        List(items, selection: $selected, rowContent: rowView(_:))
            .refreshable(action: {
                await dataFetcher.update()
            })
            .searchable(text: $queryString, placement: .automatic)
            .toolbar(content: {
                let sortOptions = T.sortOptions
                if sortOptions.count > 1 {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        SortOrderMenu(sort: $sort, options: T.sortOptions)
                    }
                }
            })
            .listStyle(.plain)
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
            self.menuBuilder.contextMenu(for: item, with: appModel)
        })
    }
    
    private func destination(for item: T) -> NavigationDestination? {
        switch item {
        case let nowModel as NowListing:
            return .now(nowModel.owner)
        default:
            if context != .profile {
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

