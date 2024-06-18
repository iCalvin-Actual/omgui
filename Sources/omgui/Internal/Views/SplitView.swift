//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/10/23.
//

import SwiftUI

@MainActor
struct SplitView: View {
    
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    @Environment(\.horizontalSizeClass)
    var sizeClass
    
    @State
    var selected: NavigationItem?
    @State
    var visibility: NavigationSplitViewVisibility = .all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $visibility, preferredCompactColumn: .constant(.sidebar)) {
            Sidebar(selected: $selected, model: .init(sceneModel.addressBook))
        } detail: {
            let destination = selected?.destination ?? .account
            NavigationStack {
                destinationView(destination)
            }
        }
        .onAppear {
            if sizeClass != .compact && selected == nil {
                selected = .account
            }
        }
    }
    
    @ViewBuilder
    func destinationView(_ destination: NavigationDestination? = .webpage("app")) -> some View {
            sceneModel.destinationConstructor.destination(destination)
                .navigationDestination(for: NavigationDestination.self, destination: sceneModel.destinationConstructor.destination(_:))
    }
}
