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
        ListView<PasteModel, PasteRowView, EmptyView>(
            context: context,
            filters: .everyone,
            dataFetcher: fetcher,
            rowBuilder: pasteView(_:)
        )
    }
    
    func pasteView(_ model: PasteModel) -> PasteRowView {
        PasteRowView(model: model, context: context)
    }
}
