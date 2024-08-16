//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/12/23.
//

import Blackbird
import SwiftUI

struct DirectoryView: View {
    
    let fetcher: AddressDirectoryDataFetcher
    
    var body: some View {
        ModelBackedListView<AddressModel, ListRow, EmptyView>(
            filters: .everyone,
            dataFetcher: fetcher,
            rowBuilder: { _ in return nil as ListRow<AddressModel>?}
        )
    }
}
