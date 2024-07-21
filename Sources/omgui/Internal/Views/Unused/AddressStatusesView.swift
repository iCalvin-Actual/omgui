//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftData
import SwiftUI

struct AddressStatusesView: View {
    
    @Environment(SceneModel.self)
    var sceneModel
    
    let address: AddressName
    
    @Query
    var models: [AddressBioModel]
    var bio: AddressBioModel? {
        models.first(where: { $0.address == address })
    }
    
    @State
    var expand: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            if let bio {
                AddressBioLabel(expanded: $expand, bio: bio)
            }
            StatusList(addresses: [address])
        }
        .onAppear {
            guard models.isEmpty else {
                return
            }
            Task {
                try await sceneModel.fetchBio(address)
                try await sceneModel.fetchStatuses([address])
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ThemedTextView(text: address.addressDisplayString + ".statusLog")
            }
        }
    }
}
