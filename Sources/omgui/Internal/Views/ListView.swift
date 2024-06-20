//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct ListView<T: Listable, V: View, H: View>: View {
    
    @Environment(\.horizontalSizeClass)
    var sizeClass
    @Environment(SceneModel.self)
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
        sizeAppropriateBody
            .onAppear(perform: {
                if !dataFetcher.loading {
                    Task {
                        await dataFetcher.updateIfNeeded()
                    }
                }
            })
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
    var sizeAppropriateBody: some View {
        if sizeClass == .compact || dataFetcher.noContent {
            compactBody
        } else {
            GeometryReader { proxy in
                switch proxy.size.width > 330 {
                case true:
                    regularBody
                default:
                    compactBody
                }
            }
        }
    }
    
    @ViewBuilder
    var compactBody: some View {
        searchableList
            .listRowBackground(Color.clear)
    }
    
    @ViewBuilder
    var searchableList: some View {
        if self.allowSearch {
            list
                .searchable(text: $queryString, placement: .automatic)
        } else {
            list
        }
    }
    
    @ViewBuilder
    var regularBody: some View {
        HStack(spacing: 0) {
            compactBody
                .frame(maxWidth: 330)
            GeometryReader { proxy in
                regularBodyContent
                    .frame(maxWidth: .infinity)
                    .environment(\.horizontalSizeClass, proxy.size.width > 500 ? .regular : .compact)
            }
        }
    }
    
    @ViewBuilder
    var regularBodyContent: some View {
        if let selected = selected {
            sceneModel.destinationConstructor.destination(destination(for: selected))
        } else {
            ThemedTextView(text: "no selection")
                .padding()
        }
    }
    
    @ViewBuilder
    var list: some View {
        List(selection: $selected) {
            listItems
                .listRowBackground(Color.clear)
        }
        .refreshable(action: {
            await dataFetcher.perform()
        })
        .listStyle(.plain)
        .onAppear(perform: {
            guard sizeClass == .regular, dataFetcher.loaded, selected == nil else {
                return
            }
            selected = dataFetcher.listItems.first
        })
    }
    
    @ViewBuilder
    var listItems: some View {
        if let headerBuilder = headerBuilder {
            Section {
                headerBuilder()
                    .listRowSeparator(.hidden)
            }
            Section(dataFetcher.title) {
                listContent
                    .padding(.horizontal)
            }
        } else {
            listContent
                .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    var listContent: some View {
        if !items.isEmpty {
            ForEach(items, content: rowView(_:) )
        } else if dataFetcher.loading {
            LoadingView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            emptyRowView()
        }
    }
    
    @ViewBuilder
    func emptyRowView() -> some View {
        HStack {
            Spacer()
            ThemedTextView(text: "empty")
                .font(.title3)
                .bold()
                .padding()
            Spacer()
        }
        .listRowSeparator(.hidden, edges: .all)
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
    
    @ViewBuilder
    func rowView(_ item: T) -> some View {
        rowBody(item)
            .tag(item)
            .listRowSeparator(.hidden, edges: .all)
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .contextMenu(menuItems: {
                self.menuBuilder.contextMenu(for: item, sceneModel: sceneModel)
            })
    }
    
    @ViewBuilder
    func rowBody(_ item: T) -> some View {
        switch sizeClass {
        case .compact:
            ZStack(alignment: .leading) {
                if let destination = destination(for: item) {
                    NavigationLink(value: destination) {
                        EmptyView()
                    }
                    .opacity(0)
                }
                
                buildRow(item)
            }
        default:
            buildRow(item)
        }
    }
    
    private func destination(for item: T) -> NavigationDestination? {
        switch item {
        case let nowModel as NowListing:
            return .now(nowModel.owner)
        case let pasteModel as PasteModel:
            return .paste(pasteModel.addressName, title: pasteModel.name)
        case let purlModel as PURLModel:
            return .purl(purlModel.addressName, title: purlModel.value)
        case let statusModel as StatusModel:
            return .status(statusModel.address, id: statusModel.id)
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

