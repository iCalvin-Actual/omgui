//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct AddressPURLsView: View {
    @ObservedObject
    var fetcher: AddressPURLsDataFetcher
    
    var body: some View {
        ListView<PURLResponse, PURLRowView, EmptyView>(
            filters: .everyone,
            dataFetcher: fetcher,
            rowBuilder: purlView(_:)
        )
    }
    
    func purlView(_ model: PURLResponse) -> PURLRowView {
        PURLRowView(model: model)
    }
}
