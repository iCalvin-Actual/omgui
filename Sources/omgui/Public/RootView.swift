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

struct RootView: View {
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    
    let appModel: AppModel
    
    var body: some View {
        appropriateNavigation
            .environmentObject(SceneModel(appModel: appModel))
    }
    
    @ViewBuilder
    var appropriateNavigation: some View {
        switch horizontalSizeClass {
        case .compact:
            TabBar()
        default:
            SplitView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var appModel: AppModel = .init(client: .sample, dataInterface: SampleData())
    static var previews: some View {
        RootView(appModel: appModel)
    }
}
