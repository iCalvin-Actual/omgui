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
    
    let addressBook: AddressBook
    let accountAuthDataFetcher: AccountAuthDataFetcher
    let db: Blackbird.Database
    
    let sceneModel: SceneModel
    
    init(sceneModel: SceneModel, addressBook: AddressBook, accountAuthDataFetcher: AccountAuthDataFetcher, db: Blackbird.Database) {
        self.addressBook = addressBook
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

//struct ContentView_Previews: PreviewProvider {
//    @StateObject
//    static var database = try! Blackbird.Database.inMemoryDatabase()
//    
//    static var previews: some View {
//        RootView()
//    }
//}
