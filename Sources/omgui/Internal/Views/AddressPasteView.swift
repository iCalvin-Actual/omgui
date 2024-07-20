//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftData
import SwiftUI

struct AddressPasteView: View {
    @State
    var sort: Sort = .alphabet
    
    let address: AddressName
    
    @Query
    var pastes: [AddressPasteModel]
    var addressPastes: [AddressPasteModel] {
        pastes.filter({ $0.owner == address })
    }
    
    var body: some View {
        ListView<AddressPasteModel, PasteRowView, EmptyView>(
            filters: .everyone,
            data: addressPastes,
            rowBuilder: pasteView(_:)
        )
    }
    
    func pasteView(_ model: AddressPasteModel) -> PasteRowView {
        PasteRowView(model: model)
    }
}
