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
            .task { [addressBook] in
                await addressBook.autoFetch()
            }
            .environment(accountAuthDataFetcher)
            .environment(sceneModel)
    }
    
    @ViewBuilder
    var appropriateNavigation: some View {
//        if horizontalSizeClass == .regular {
//            SplitView()
//        } else {
            TabBar(sceneModel: sceneModel)
//        }
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
