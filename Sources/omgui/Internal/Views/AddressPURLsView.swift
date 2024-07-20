//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftData
import SwiftUI

struct AddressPURLsView: View {
    @Environment(SceneModel.self)
    var sceneModel
    
    let address: AddressName
    
    @Query
    var purls: [AddressPURLModel]
    var addressPURLs: [AddressPURLModel] {
        purls.filter({ $0.owner == address })
    }
    
    var body: some View {
        ListView<AddressPURLModel, PURLRowView, EmptyView>(
            filters: .everyone,
            data: addressPURLs,
            rowBuilder: purlView(_:),
            refresh: refresh
        )
        .onAppear {
            refresh()
        }
    }
    
    func refresh() {
        Task {
            try await sceneModel.fetchPURLS(address)
        }
    }
    
    func purlView(_ model: AddressPURLModel) -> PURLRowView {
        PURLRowView(model: model)
    }
}
