//
//  ContentView.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Blackbird
import SwiftUI

struct RootView: View {
    
    
    let addressBook: AddressBook
    let accountAuthDataFetcher: AccountAuthDataFetcher
    let db: Blackbird.Database
    
    init(addressBook: AddressBook, accountAuthDataFetcher: AccountAuthDataFetcher, db: Blackbird.Database) {
        self.addressBook = addressBook
        self.accountAuthDataFetcher = accountAuthDataFetcher
        self.db = db
    }
    
    var body: some View {
        SplitView()
            .task { [addressBook] in
                await addressBook.autoFetch()
            }
            .environment(accountAuthDataFetcher)
            .environment(
                SceneModel(
                    addressBook: addressBook,
                    interface: accountAuthDataFetcher.interface,
                    database: db
                )
            )
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
