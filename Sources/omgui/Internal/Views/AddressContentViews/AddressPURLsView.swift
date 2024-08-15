//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct AddressPURLsView: View {
    let fetcher: AddressPURLsDataFetcher
    
    var body: some View {
        ModelBackedListView<PURLModel, PURLRowView, EmptyView>(
            filters: .everyone,
            dataFetcher: fetcher,
            rowBuilder: purlView(_:)
        )
    }
    
    func purlView(_ model: PURLModel) -> PURLRowView {
        PURLRowView(model: model)
    }
}
