//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/12/23.
//

import SwiftUI

struct AppropriateDirectoryView: View {
    @ObservedObject
    var fetcher: AddressDirectoryDataFetcher
    
    var body: some View {
        ListView<AddressModel, ListRow, EmptyView>(
            context: .column,
            filters: .everyone,
            dataFetcher: fetcher,
            rowBuilder: { _ in return nil as ListRow<AddressModel>?}
        )
    }
}

@MainActor
struct DirectoryView: View {
    @ObservedObject
    var dataFetcher: AddressDirectoryDataFetcher
    
    @AppStorage("app.lol.directory.showPinned", store: .standard)
    var showPinned: Bool = true
    
    @Environment(SceneModel.self)
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
    
    var body: some View {
        listBody
            .toolbarRole(.editor)
    }
    
    @ViewBuilder
    var listBody: some View {
        ListView<AddressModel, ListRow<AddressModel>, EmptyView>(dataFetcher: dataFetcher, rowBuilder: { _ in return nil as ListRow<AddressModel>? })
    }
    
    @ViewBuilder
    var addressBody: some View {
        if let selectedAddress = selected {
            AddressSummaryView(addressSummaryFetcher: sceneModel.addressBook.addressSummary(selectedAddress), context: .profile, allowEditing: false, selectedPage: .profile)
        } else {
            ThemedTextView(text: "select an @address")
        }
    }
}
