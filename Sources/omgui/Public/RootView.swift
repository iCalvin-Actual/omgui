//
//  ContentView.swift
//  appDOTlol
//
//  Created by Calvin Chestnut on 3/5/23.
//

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
    
    @Environment(\.modelContext)
    var modelContext
    
    let fetchConstructor: FetchConstructor
    
    @AppStorage("app.lol.auth")
    var authKey: String = ""
    @AppStorage("app.lol.blocked")
    var globalBlockedAddresses: String = ""
    @AppStorage("app.lol.cache.myAddresses")
    var localAddressesCache: String = ""
    @AppStorage("app.lol.cache.blocked")
    var cachedBlockList: String = ""
    @AppStorage("app.lol.cache.pinned")
    var currentlyPinnedAddresses: String = "adam&&&app"
    @AppStorage("app.lol.cache.name")
    var myName: String = ""
    
    
    @SceneStorage("app.lol.address")
    var actingAddress: String = ""
    
    var body: some View {
        NavigationView()
            .environment(
                SceneModel(
                    fetchConstructor: fetchConstructor,
                    context: modelContext,
                    authKey: $authKey,
                    globalBlocklist: $globalBlockedAddresses,
                    localBlocklist: $cachedBlockList,
                    pinnedAddresses: $currentlyPinnedAddresses,
                    myAddresses: $localAddressesCache,
                    myName: $myName,
                    actingAddress: $actingAddress
                )
            )
    }
}
