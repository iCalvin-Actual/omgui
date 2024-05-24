//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct AddressPURLView: View {
    @ObservedObject
    var fetcher: AddressPURLsDataFetcher
    
    let context: ViewContext
    
    var body: some View {
        ListView<PURLModel, PURLRowView, EmptyView>(
            context: context,
            filters: .everyone,
            dataFetcher: fetcher,
            rowBuilder: purlView(_:)
        )
    }
    
    func purlView(_ model: PURLModel) -> PURLRowView {
        PURLRowView(model: model, context: context)
    }
}
