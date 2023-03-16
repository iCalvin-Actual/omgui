//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct AddressPasteView: View {
    @ObservedObject
    var fetcher: AddressPasteBinDataFetcher
    
    @State
    var sort: Sort = .alphabet
    
    let context: ViewContext
    
    var body: some View {
        ListView<PasteModel, PasteView, EmptyView>(
            context: context,
            filters: .everyone,
            dataFetcher: fetcher,
            rowBuilder: pasteView(_:)
        )
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ThemedTextView(text: AddressContent.pastebin.externalUrlString(for: fetcher.addressName), font: .callout)
                    .fontDesign(.monospaced)
            }
        }
    }
    
    func pasteView(_ model: PasteModel) -> PasteView {
        PasteView(model: model, context: context)
    }
}
