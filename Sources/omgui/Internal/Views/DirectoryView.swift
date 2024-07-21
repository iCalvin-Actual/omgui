//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/12/23.
//

import SwiftData
import SwiftUI

struct DirectoryView: View {
    @Query
    var summaries: [AddressInfoModel]
    
    var body: some View {
        ListView<AddressInfoModel, ListRow, EmptyView>(
            filters: .everyone,
            data: summaries,
            rowBuilder: { _ in return nil as ListRow<AddressInfoModel>?}
        )
    }
}
