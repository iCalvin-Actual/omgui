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
    @SceneStorage("app.lol.address")
    var actingAddress: AddressName = ""
    
    @Environment(\.blackbirdDatabase)
    var db
    
    let fetchConstructor: FetchConstructor
    
    var body: some View {
        NavigationView()
            .environment(
                SceneModel(actingAddress: actingAddress, fetchConstructor: fetchConstructor)
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
