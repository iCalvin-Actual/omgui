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
    
    @Environment(SceneModel.self)
    var sceneModel
    
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
    var blockedInfo: [AddressInfoModel] {
        addresses.filter({ sceneModel.addressBlocked.contains($0.owner) })
    }
    
    var body: some View {
        ListView<AddressInfoModel, ListRow<AddressInfoModel>, EmptyView>(filters: .none, data: blockedInfo, rowBuilder: { _ in return nil as ListRow<AddressInfoModel>? })
            .onAppear(perform: { needsRefresh = false })
    }
}
