//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct AddressPastesView: View {
    @ObservedObject
    var fetcher: AddressPasteBinDataFetcher
    
    @State
    var sort: Sort = .alphabet
    
    var body: some View {
        ModelBackedListView<PasteModel, PasteRowView, EmptyView>(
            filters: .everyone,
            dataFetcher: fetcher,
            rowBuilder: pasteView(_:)
        )
    }
    
    func pasteView(_ model: PasteModel) -> PasteRowView {
        PasteRowView(model: model)
    }
}