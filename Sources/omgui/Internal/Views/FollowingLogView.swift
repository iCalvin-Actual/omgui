//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/13/23.
//

import Combine
import SwiftData
import SwiftUI

struct FollowingLogView: View {
    @SceneStorage("app.lol.address")
    var actingAddress: AddressName = ""
    @Environment(SceneModel.self)
    var sceneModel
    
    @Query
    var addressInfo: [AddressInfoModel]
    var myFollowing: [AddressName] {
        guard let info = addressInfo.first(where: { $0.owner == actingAddress }) else {
            return []
        }
        return info.following
    }
    
    @State
    var needsRefresh: Bool = false
    
    var body: some View {
        StatusList(addresses: myFollowing)
            .onAppear {
                Task {
                    try await sceneModel.fetchStatuses(myFollowing)
                }
            }
            .onAppear(perform: { needsRefresh = false })
    }
}
