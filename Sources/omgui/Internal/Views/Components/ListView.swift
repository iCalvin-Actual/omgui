//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct ModelBackedListView<T: ModelBackedListable, V: View, H: View>: View {
    
    @Environment(\.horizontalSizeClass)
    var sizeClass
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
    let rowBuilder: ((T) -> V?)
    
    @ViewBuilder
    let headerBuilder: (() -> H)?
    
    @State
    var selected: T?
    @State
    var queryString: String = ""
    @State
    var sort: Sort = T.defaultSort
    
    @ObservedObject
    var dataFetcher: ModelBackedListDataFetcher<T>
    
    var menuBuilder: ContextMenuBuilder<T> = .init()
    
    init(
        filters: [FilterOption] = .everyone,
        allowSearch: Bool = true,
        allowFilter: Bool = true,
        dataFetcher: ModelBackedListDataFetcher<T>,
        rowBuilder: @escaping (T) -> V?,
        headerBuilder: (() -> H)? = nil
    ) {
        self.filters = filters
        self.allowSearch = allowSearch
        self.allowFilter = allowFilter
        self._dataFetcher = .init(wrappedValue: dataFetcher)
        self.rowBuilder = rowBuilder
        self.headerBuilder = headerBuilder
    }
    
    var items: [T] {
        dataFetcher.results
    }
    
    var body: some View {
        toolbarAwareBody
            .task { @MainActor [dataFetcher] in
                if !dataFetcher.loading {
                    await dataFetcher.updateIfNeeded()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
            .onChange(of: sort, { oldValue, newValue in
                dataFetcher.sort = newValue
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
            .onChange(of: filters, { oldValue, newValue in
                dataFetcher.filters = newValue
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
                .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        } else {
            sizeAppropriateBody
        }
    }
    
    @ViewBuilder
    var sizeAppropriateBody: some View {
        if sizeClass == .compact {
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
            
            if dataFetcher.nextPage != nil {
                ProgressView()
                  .frame(maxWidth: .infinity, maxHeight: .infinity)
                  .foregroundColor(.black)
                  .foregroundColor(.red)
                  .onAppear {
                      Task { [dataFetcher] in
                          try await dataFetcher.fetchModels()
                      }
                  }
            }
        }
        .task { [dataFetcher] in
            dataFetcher.loading = true
            dataFetcher.loaded = false
            await dataFetcher.updateIfNeeded(forceReload: true)
            dataFetcher.loading = false
            dataFetcher.loaded = true
        }
        .refreshable(action: { [dataFetcher] in
            dataFetcher.loading = true
            dataFetcher.loaded = false
            await dataFetcher.updateIfNeeded(forceReload: true)
            dataFetcher.loading = false
            dataFetcher.loaded = true
        })
        .listStyle(.plain)
        .onAppear(perform: {
            guard sizeClass == .regular, dataFetcher.loaded, selected == nil else {
                return
            }
            selected = dataFetcher.results.first
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
        if let constructedView = rowBuilder(item) {
            constructedView
        } else {
            ListRow(model: item, selected: $selected)
                .contextMenu(menuItems: {
                    self.menuBuilder.contextMenu(for: item, fetcher: dataFetcher, sceneModel: sceneModel)
                }) {
                    sceneModel.destinationConstructor.destination(destination(for: item))
                        .environment(sceneModel)
                        .environment(authFetcher)
                }
        }
    }
}

struct ListView<T: Listable, V: View, H: View>: View {
    
    @Environment(\.horizontalSizeClass)
    var sizeClass
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    @Environment(\.viewContext)
    var context: ViewContext
    
    let filters: [FilterOption]
    
    let allowSearch: Bool
    let allowFilter: Bool
    
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
    
    @ObservedObject
    var dataFetcher: ListDataFetcher<T>
    
    var menuBuilder: ContextMenuBuilder<T> = .init()
    
    init(
        filters: [FilterOption] = .everyone,
        allowSearch: Bool = true,
        allowFilter: Bool = true,
        dataFetcher: ListDataFetcher<T>,
        rowBuilder: @escaping (T) -> V?,
        headerBuilder: (() -> H)? = nil
    ) {
        self.filters = filters
        self.allowSearch = allowSearch
        self.dataFetcher = dataFetcher
        self.allowFilter = allowFilter
        self.rowBuilder = rowBuilder
        self.headerBuilder = headerBuilder
    }
    
    var items: [T] {
        var filters = filters
        if !queryString.isEmpty {
            filters.append(.query(queryString))
        }
        return filters
            .applyFilters(to: dataFetcher.results, in: sceneModel)
            .sorted(with: sort)
    }
    
    var body: some View {
        toolbarAwareBody
            .task { [dataFetcher] in
                if !dataFetcher.loading {
                    Task {
                        await dataFetcher.updateIfNeeded()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
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
                .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        } else {
            sizeAppropriateBody
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
        }
        .refreshable(action: { [dataFetcher] in
            await dataFetcher.updateIfNeeded(forceReload: true)
        })
        .listStyle(.plain)
        .onAppear(perform: {
            guard sizeClass == .regular, dataFetcher.loaded, selected == nil else {
                return
            }
            selected = dataFetcher.results.first
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
                self.menuBuilder.contextMenu(for: item, fetcher: dataFetcher, sceneModel: sceneModel)
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
//            if sceneModel.accountModel.myAddresses.contains(pasteModel.addressName) {
//                return .editPaste(pasteModel.addressName, title: pasteModel.name)
//            }
            return .paste(pasteModel.addressName, id: pasteModel.name)
        case let purlModel as PURLModel:
//            if sceneModel.accountModel.myAddresses.contains(purlModel.addressName) {
//                return .editPURL(purlModel.addressName, title: purlModel.value)
//            }
            return .purl(purlModel.addressName, id: purlModel.name)
        case let statusModel as StatusModel:
            if sceneModel.addressBook.myAddresses.contains(statusModel.address) {
//                return .editStatus(statusModel.address, id: statusModel.id)
            }
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

