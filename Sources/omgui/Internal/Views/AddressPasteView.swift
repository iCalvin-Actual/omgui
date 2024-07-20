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
    
    var body: some View {
        ListView<PasteResponse, PasteRowView, EmptyView>(
            filters: .everyone,
            dataFetcher: fetcher,
            rowBuilder: pasteView(_:)
        )
    }
    
    func pasteView(_ model: PasteResponse) -> PasteRowView {
        PasteRowView(model: model)
    }
}
