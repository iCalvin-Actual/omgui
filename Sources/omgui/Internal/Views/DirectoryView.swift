//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/12/23.
//

import SwiftUI

struct DirectoryView: View {
    @ObservedObject
    var fetcher: AddressDirectoryDataFetcher
    
    var body: some View {
        ListView<AddressModel, ListRow, EmptyView>(
            filters: .everyone,
            data: fetcher.listItems,
            rowBuilder: { _ in return nil as ListRow<AddressModel>?}
        )
    }
}
