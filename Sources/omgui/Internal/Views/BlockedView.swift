//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/13/23.
//

import SwiftData
import SwiftUI

struct BlockedView: View {
    
    @SceneStorage("app.lol.address")
    var actingAddress: AddressName = ""
    
    let targetAddress: AddressName
    
    var address: AddressName {
        guard targetAddress != .autoUpdatingAddress else {
            return actingAddress
        }
        return targetAddress
    }
    
    @State
    var needsRefresh: Bool = false
    
    @Query
    var addresses: [AddressInfoModel]
    var targetInfo: AddressInfoModel? {
        addresses.first(where: { $0.owner == address })
    }
    
    var blockedAddresses: [AddressInfoModel] {
        guard let targetInfo else {
            return []
        }
        
        return addresses.filter({ model in
            targetInfo.blocked.contains(where: { $0 == model.owner })
        })
    }
    
    var body: some View {
        ListView<AddressInfoModel, ListRow<AddressInfoModel>, EmptyView>(filters: .none, data: blockedAddresses, rowBuilder: { _ in return nil as ListRow<AddressInfoModel>? })
            .onAppear(perform: { needsRefresh = false })
    }
}
