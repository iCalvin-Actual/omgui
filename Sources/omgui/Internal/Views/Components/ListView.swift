//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct ListView<T: Listable, H: View>: View {
    
    @Environment(\.horizontalSizeClass)
    var horizontalSize
    @Environment(\.verticalSizeClass)
    var verticalSize
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    @Environment(AccountAuthDataFetcher.self)
    var authFetcher: AccountAuthDataFetcher
    
    @Environment(\.viewContext)
    var context: ViewContext
    
    @State
    var filters: [FilterOption]
    
    let allowSearch: Bool
    let allowFilter: Bool
    
    @ViewBuilder
    let headerBuilder: (() -> H)?
    
    @State
    var selected: T?
    @State
    var queryString: String = ""
    @State
    var sort: Sort = T.defaultSort
    
    @ObservedObject
    var dataFetcher: ListFetcher<T>
    
    var menuBuilder: ContextMenuBuilder<T> = .init()
    
    init(
        filters: [FilterOption] = .everyone,
        allowSearch: Bool = true,
        allowFilter: Bool = true,
        dataFetcher: ListFetcher<T>,
        headerBuilder: (() -> H)? = nil
    ) {
        self.filters = filters
        self.allowSearch = allowSearch
        self.dataFetcher = dataFetcher
        self.allowFilter = allowFilter
        self.headerBuilder = headerBuilder
    }
    
    var items: [T] {
        if T.self is any BlackbirdListable.Type {
            return dataFetcher.results
        } else {
            var filters = filters
            if !queryString.isEmpty {
                filters.append(.query(queryString))
            }
            return filters
                .applyFilters(to: dataFetcher.results, in: sceneModel)
                .sorted(with: sort)
        }
    }
    
    var body: some View {
        toolbarAwareBody
            .task { @MainActor [dataFetcher] in
                if !dataFetcher.loading {
                    Task {
                        await dataFetcher.updateIfNeeded()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
            .onChange(of: sort, { oldValue, newValue in
                dataFetcher.sort = newValue
            })
            .onChange(of: filters, { oldValue, newValue in
                dataFetcher.filters = newValue
            })
            .onChange(of: queryString, { oldValue, newValue in
                var newFilters = filters
                newFilters.removeAll(where: { filter in
                    switch filter {
                    case .query:
                        return true
                    default:
                        return false
                    }
                })
                defer {
                    dataFetcher.results = []
                    dataFetcher.nextPage = 0
                    Task { [dataFetcher] in
                        await dataFetcher.updateIfNeeded(forceReload: true)
                    }
                }
                guard !newValue.isEmpty else {
                    filters = newFilters
                    return
                }
                newFilters.append(.query(newValue))
                filters = newFilters
            })
            .toolbar {
                let sortOptions = T.sortOptions
                if sortOptions.count > 1, dataFetcher.results.count > 1, allowFilter {
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
    var toolbarAwareBody: some View {
        if #available(iOS 18.0, *) {
            sizeAppropriateBody
        } else {
            sizeAppropriateBody
        }
    }
    
    @ViewBuilder
    var sizeAppropriateBody: some View {
        if horizontalSize == .compact {
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
            .animation(.easeInOut(duration: 0.3), value: dataFetcher.loaded)
            .listRowBackground(Color.clear)
    }
    
    @ViewBuilder
    var searchableList: some View {
        if allowSearch && (dataFetcher.loaded || !queryString.isEmpty) {
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
                .environment(\.viewContext, .column)
            GeometryReader { proxy in
                regularBodyContent
                    .frame(maxWidth: .infinity)
                    .environment(\.viewContext, .detail)
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
                .padding(.vertical, 4)
            
            if dataFetcher.nextPage != nil && queryString.isEmpty {
                LoadingView()
                    .padding(32)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        Task { [dataFetcher] in
                            dataFetcher.fetchNextPageIfNeeded()
                        }
                    }
            }
        }
        .task { [dataFetcher] in
            guard !dataFetcher.loaded else { return }
            dataFetcher.loading = true
            await dataFetcher.updateIfNeeded(forceReload: true)
            dataFetcher.loading = false
            dataFetcher.loaded = true
        }
        .refreshable(action: { [dataFetcher] in
            dataFetcher.loaded = false
            dataFetcher.loading = true
            await dataFetcher.updateIfNeeded(forceReload: true)
            dataFetcher.loading = false
            dataFetcher.loaded = true
        })
        .listStyle(.plain)
        .onReceive(dataFetcher.$loaded, perform: { _ in
            var newSelection: T?
            switch (
                horizontalSize == .regular,
                dataFetcher.loaded,
                selected == nil
            ) {
            case (false, true, false):
                newSelection = nil
            case (true, true, true):
                newSelection = dataFetcher.results.first
            default:
                return
            }
            
            try? withAnimation { @MainActor in
                self.selected = newSelection
            }
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
        if dataFetcher.noContent {
            emptyRowView()
        } else if !items.isEmpty {
            ForEach(items, content: rowView(_:) )
        } else {
            EmptyView()
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
                self.menuBuilder.contextMenu(for: item, fetcher: dataFetcher, sceneModel: sceneModel)
            }) {
                ListRow(model: item, selected: .constant(item))
                    .environment(sceneModel)
                    .environment(authFetcher)
            }
    }
    
    @ViewBuilder
    func rowBody(_ item: T) -> some View {
        switch horizontalSize {
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
            return .paste(pasteModel.addressName, id: pasteModel.name)
        case let purlModel as PURLModel:
            return .purl(purlModel.addressName, id: purlModel.name)
        case let statusModel as StatusModel:
            return .status(statusModel.address, id: statusModel.id)
        case let addressModel as AddressModel:
            return .address(addressModel.addressName)
        default:
            if context == .column {
                return .address(item.addressName)
            }
        }
        return nil
    }
    
    @ViewBuilder
    func buildRow(_ item: T) -> some View {
        ListRow<T>(model: item, selected: $selected)
    }
}

