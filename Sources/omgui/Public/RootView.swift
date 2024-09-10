//
//  ContentView.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Blackbird
import SwiftUI

struct RootView: View {
    
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    
    let accountAuthDataFetcher: AccountAuthDataFetcher
    let db: Blackbird.Database
    
    let sceneModel: SceneModel
    var addressBook: AddressBook { sceneModel.addressBook }
    
    init(sceneModel: SceneModel, accountAuthDataFetcher: AccountAuthDataFetcher, db: Blackbird.Database) {
        self.accountAuthDataFetcher = accountAuthDataFetcher
        self.db = db
        self.sceneModel = sceneModel
    }
    
    var body: some View {
        appropriateNavigation
            .task { @MainActor [statusFetcher = sceneModel.statusFetcher, addressBook] in
                await addressBook.autoFetch()
                try? await statusFetcher.fetchRemote()
                try? await statusFetcher.fetchBacklog()
            }
            .environment(accountAuthDataFetcher)
            .environment(sceneModel)
    }
    
    @ViewBuilder
    var appropriateNavigation: some View {
        if #available(iOS 18.0, *) {
            TabBar(sceneModel: sceneModel)
        } else {
            SplitView()
        }
    }
}

#Preview {
    RootView(sceneModel: .sample, accountAuthDataFetcher: .init(authKey: nil, client: .sample, interface: SampleData()), db: SceneModel.sample.database)
}
