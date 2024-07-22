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
    
    @Environment(\.viewContext)
    var context: ViewContext
    let filters: [FilterOption]
    
    let allowSearch: Bool
    let allowFilter: Bool
    
    let data: [T]
    
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
    
    let refresh: () -> Void
    
    init(
        filters: [FilterOption] = .everyone,
        allowSearch: Bool = true,
        allowFilter: Bool = true,
        data: [T],
        rowBuilder: @escaping (T) -> V?,
        headerBuilder: (() -> H)? = nil,
        refresh: @escaping () -> Void = {}
    ) {
        self.filters = filters
        self.allowSearch = allowSearch
        self.allowFilter = allowFilter
        self.data = data
        self.rowBuilder = rowBuilder
        self.headerBuilder = headerBuilder
        self.refresh = refresh
    }
    
    var items: [T] {
        var filters = filters
        if !queryString.isEmpty {
            filters.append(.query(queryString))
        }
        return filters
            .applyFilters(to: data, in: sceneModel)
            .sorted(with: sort)
    }
    
    var body: some View {
        toolbarAwareBody
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
            .toolbar {
                let sortOptions = T.sortOptions
                if sortOptions.count > 1, data.count > 1, allowFilter {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        SortOrderMenu(sort: $sort, options: T.sortOptions)
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
        if sizeClass == .compact || data.isEmpty {
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
        .refreshable(action: {
            refresh()
        })
        .listStyle(.plain)
        .onAppear(perform: {
            guard sizeClass == .regular, selected == nil else {
                return
            }
            selected = items.first
        })
    }
    
    @ViewBuilder
    var listItems: some View {
        if let headerBuilder = headerBuilder {
            Section {
                headerBuilder()
                    .listRowSeparator(.hidden)
            }
            Section("items") {
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
        case let pasteModel as PasteResponse:
//            if sceneModel.accountModel.myAddresses.contains(pasteModel.addressName) {
//                return .editPaste(pasteModel.addressName, title: pasteModel.name)
//            }
            return .paste(pasteModel.owner, title: pasteModel.name)
        case let purlModel as PURLResponse:
//            if sceneModel.accountModel.myAddresses.contains(purlModel.addressName) {
//                return .editPURL(purlModel.addressName, title: purlModel.value)
//            }
            return .purl(purlModel.owner, title: purlModel.value)
        case let StatusResponse as StatusResponse:
            if sceneModel.myAddresses.contains(StatusResponse.address) {
//                return .editStatus(StatusResponse.address, id: StatusResponse.id)
            }
            return .status(StatusResponse.address, id: StatusResponse.id)
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

