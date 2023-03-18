//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/10/23.
//

import SwiftUI

struct SplitView: View {
    @EnvironmentObject
    var sceneModel: SceneModel
    
    @State
    var selected: NavigationItem? = .pinnedAddress("app")
    
    var body: some View {
        NavigationSplitView {
            Sidebar(selected: $selected, model: .init(sceneModel: sceneModel))
                .navigationDestination(for: NavigationDestination.self, destination: sceneModel.destinationConstructor.destination(_:))
        } content: {
            let destination = selected?.destination ?? .lists
            destinationView(destination)
                .navigationDestination(for: NavigationDestination.self, destination: sceneModel.destinationConstructor.destination(_:))
        } detail: {
            sceneModel.destinationConstructor.destination(.webpage("calvin"))
        }
    }
    
    @ViewBuilder
    func destinationView(_ destination: NavigationDestination? = .webpage("app")) -> some View {
        sceneModel.destinationConstructor.destination(destination)
    }
}
