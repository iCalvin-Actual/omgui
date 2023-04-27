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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ThemedTextView(text: AddressContent.purl.externalUrlString(for: fetcher.addressName), font: .callout)
                    .fontDesign(.monospaced)
            }
        }
    }
    
    func purlView(_ model: PURLModel) -> PURLRowView {
        PURLRowView(model: model, context: context)
    }
}
