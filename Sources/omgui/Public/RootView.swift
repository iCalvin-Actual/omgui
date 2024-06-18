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
    @SceneStorage("app.lol.address")
    var actingAddress: AddressName = ""
    
    let fetchConstructor: FetchConstructor
    
    var body: some View {
        NavigationView()
            .environment(
                SceneModel(actingAddress: actingAddress, fetchConstructor: fetchConstructor)
            )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(fetchConstructor: .init(client: .sample, interface: SampleData()))
    }
}
