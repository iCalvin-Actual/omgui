//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct ListView<T: Listable, H: View>: View {
    
    @Namespace
    var namespace
    
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
    
    func usingRegular(_ width: CGFloat) -> Bool {
        TabBar.usingRegularTabBar(sizeClass: horizontalSize, width: width)
    }
    
    init(
        filters: [FilterOption] = T.defaultFilter,
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
                dataFetcher.fetchNextPageIfNeeded()
            }
            .onAppear {
                guard horizontalSize == .compact, selected != nil else {
                    return
                }
                withAnimation {
                    selected = nil
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
                if (T.sortOptions.count > 1 || T.filterOptions.count > 1), allowFilter {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        SortOrderMenu(sort: $sort, filters: $filters, sortOptions: T.sortOptions, filterOptions: T.filterOptions)
                    }
                }
                
                if headerBuilder == nil {
                    ToolbarItem(placement: .topBarLeading) {
                        ThemedTextView(text: dataFetcher.title)
                    }
                }
            }
    }
    
    @ViewBuilder
    var toolbarAwareBody: some View {
        if #available(iOS 18.0, visionOS 2.0,*) {
            sizeAppropriateBody
                .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        } else {
            sizeAppropriateBody
        }
    }
    
    @ViewBuilder
    var sizeAppropriateBody: some View {
        GeometryReader { proxy in
            if horizontalSize == .compact {
                compactBody(width: proxy.size.width)
            } else {
                if usingRegular(proxy.size.width) {
                    regularBody(actingWidth: proxy.size.width)
                } else {
                    compactBody(width: proxy.size.width)
                        .environment(\.horizontalSizeClass, .compact)
                }
            }
        }
    }
    
    @ViewBuilder
    func compactBody(width: CGFloat) -> some View {
        let body: some View = {
            searchableList(width: width)
                .animation(.easeInOut(duration: 0.3), value: dataFetcher.loaded)
                .listRowBackground(Color.clear)
        }()
        if #available(iOS 18.0, visionOS 2.0, *) {
            body
                .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        } else {
            body
        }
    }
    
    @ViewBuilder
    func searchableList(width: CGFloat) ->  some View {
        if allowSearch {
            list(width: width)
                .searchable(text: $queryString, placement: .automatic)
        } else {
            list(width: width)
        }
    }
    
    @ViewBuilder
    func regularBody(actingWidth: CGFloat) -> some View {
        HStack(spacing: 0) {
            compactBody(width: 300)
                .frame(maxWidth: 300)
                .environment(\.viewContext, .column)
            regularBodyContent(actingWidth)
                .frame(maxWidth: .infinity)
                .environment(\.viewContext, context == .profile ? .profile : .detail)
                .environment(\.horizontalSizeClass, actingWidth > 300 ? .regular : .compact)
        }
        .onReceive(dataFetcher.$results) { newResults in
            if selected == nil, let item = newResults.first {
                selected = item
            }
        }
    }
    
    @ViewBuilder
    func regularBodyContent(_ actingWidth: CGFloat) -> some View {
        if let selected = selected {
            sceneModel.destinationConstructor.destination(destination(for: selected))
        } else {
            ThemedTextView(text: "no selection")
                .padding()
        }
    }
    
    @ViewBuilder
    func list(width: CGFloat) -> some View {
        let body: some View = {
            List(selection: $selected) {
                listItems(width: width)
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 4)
                
                if queryString.isEmpty && dataFetcher.nextPage != nil {
                    LoadingView()
                        .padding(32)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .listRowBackground(Color.clear)
                        .onAppear { [dataFetcher] in
                            dataFetcher.fetchNextPageIfNeeded()
                        }
                }
            }
            .refreshable(action: { [dataFetcher] in
                await dataFetcher.updateIfNeeded(forceReload: true)
            })
            .listStyle(.plain)
            .onReceive(dataFetcher.$loaded, perform: { _ in
                var newSelection: T?
                switch (
                    horizontalSize == .regular,
                    dataFetcher.loaded != nil,
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
        }()
        if #available(iOS 18.0, visionOS 2.0, *) {
            body
                .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        } else {
            body
        }
    }
    
    @ViewBuilder
    func listItems(width: CGFloat) -> some View {
        if let headerBuilder = headerBuilder {
            Section {
                headerBuilder()
                    .listRowSeparator(.hidden)
            }
            Section(dataFetcher.title) {
                listContent(width: width)
                    .padding(.horizontal)
            }
        } else {
            listContent(width: width)
                .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    func listContent(width: CGFloat) -> some View {
        if dataFetcher.noContent {
            emptyRowView()
        } else if !items.isEmpty {
            ForEach(items, content: { rowView($0, width: width) })
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
    func rowView(_ item: T, width: CGFloat) -> some View {
        rowBody(item, width: width)
            .tag(item)
            .listRowSeparator(.hidden, edges: .all)
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .contextMenu(menuItems: {
                self.menuBuilder.contextMenu(for: item, fetcher: dataFetcher, sceneModel: sceneModel)
            }) {
                AddressCard(item.addressName)
                    .environment(sceneModel)
                    .environment(authFetcher)
            }
    }
    
    @ViewBuilder
    func rowBody(_ item: T, width: CGFloat) -> some View {
        switch TabBar.usingRegularTabBar(sizeClass: horizontalSize, width: width) {
        case false:
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

