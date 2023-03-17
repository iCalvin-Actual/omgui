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
        if sceneModel.appModel.accountModel.signedIn {
            listView
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
    
    var listView: some View {
        ListView<AddressModel, ListRow<AddressModel>, EmptyView>(filters: .everyone, dataFetcher: fetcher, rowBuilder: { _ in return nil as ListRow<AddressModel>? })
    }
}
