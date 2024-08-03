//
//  ContentView.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Blackbird
import SwiftUI

struct Selections {
    var destination: NavigationItem?
    var address: AddressModel?
}

class Router: ObservableObject {
    @Published
    var navPath: NavigationPath = .init()
}

@MainActor
struct RootView: View {
    
    @Environment(\.blackbirdDatabase)
    var db
    
    let fetchConstructor: FetchConstructor
    
    @AppStorage("app.lol.auth")
    var authKey: String = ""
    @AppStorage("app.lol.blocked")
    var localBlockedAddresses: String = ""
    @AppStorage("app.lol.cache.myAddresses")
    var localAddressesCache: String = ""
    @AppStorage("app.lol.cache.pinned")
    var currentlyPinnedAddresses: String = "adam&&&app"
    @AppStorage("app.lol.cache.name")
    var myName: String = ""
    
    
    @SceneStorage("app.lol.address")
    var actingAddress: String = ""
    
    var body: some View {
        SplitView()
            .environment(
                SceneModel(
                    fetchConstructor: fetchConstructor,
                    authKey: $authKey,
                    localBlocklist: $localBlockedAddresses,
                    pinnedAddresses: $currentlyPinnedAddresses,
                    myAddresses: $localAddressesCache,
                    myName: $myName,
                    actingAddress: $actingAddress
                )
            )
    }
}

struct ContentView_Previews: PreviewProvider {
    @StateObject
    static var database = try! Blackbird.Database.inMemoryDatabase()
    
    static var previews: some View {
        RootView(fetchConstructor: .init(client: .sample, interface: SampleData(), database: database))
    }
}
