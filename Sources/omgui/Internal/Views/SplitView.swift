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
    
    @State
    var visibility: NavigationSplitViewVisibility = .all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $visibility) {
            Sidebar(selected: $selected, model: .init(sceneModel.addressBook))
                .navigationDestination(for: NavigationDestination.self, destination: sceneModel.destinationConstructor.destination(_:))
        } content: {
            let destination = selected?.destination ?? .lists
            destinationView(destination)
                .navigationDestination(for: NavigationDestination.self, destination: sceneModel.destinationConstructor.destination(_:))
        } detail: {
            NavigationStack {
                sceneModel.destinationConstructor.destination(.now("app"))
            }
        }
    }
    
    @ViewBuilder
    func destinationView(_ destination: NavigationDestination? = .webpage("app")) -> some View {
        sceneModel.destinationConstructor.destination(destination)
    }
}
