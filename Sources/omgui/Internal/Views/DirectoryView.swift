//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/12/23.
//

import Blackbird
import SwiftUI

struct DirectoryView: View {
    @ObservedObject
    var fetcher: AddressDirectoryDataFetcher
    
    @BlackbirdLiveModels({ try await AddressModel.read(from: $0, orderBy: .ascending(\.$id)) })
    var addresses
    
    var appliedItems: [AddressModel] {
        addresses.results
    }
    
    var body: some View {
        ModelBackedListView<AddressModel, ListRow, EmptyView>(
            filters: .everyone,
            dataFetcher: fetcher,
            rowBuilder: { _ in return nil as ListRow<AddressModel>?}
        )
    }
}
