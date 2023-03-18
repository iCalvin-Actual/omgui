//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/13/23.
//

import SwiftUI

struct FollowingView: View {
    
    @EnvironmentObject
    var sceneModel: SceneModel
    
    @ObservedObject
    var fetcher: AddressFollowingDataFetcher
    
    init(_ fetcher: AddressFollowingDataFetcher) {
        self.fetcher = fetcher
    }
    
    var body: some View {
        followingView
    }
    
    @ViewBuilder
    var followingView: some View {
        if sceneModel.addressBook.followingFetcher != nil {
            StatusList(fetcher: sceneModel.appModel.fetchConstructor.statusLog(for: sceneModel.addressBook.followingItems.map { $0.name }), context: .column)
        } else {
            signedOutView
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        ThemedTextView(text: "following")
                    }
                }
        }
    }
    
    @ViewBuilder
    var signedOutView: some View {
        Text("Signed Out")
    }
}
