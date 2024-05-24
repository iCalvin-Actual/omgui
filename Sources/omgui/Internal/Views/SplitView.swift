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
    @Environment(\.horizontalSizeClass)
    var sizeClass
    
    @State
    var selected: NavigationItem?
    @State
    var visibility: NavigationSplitViewVisibility = .all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $visibility, preferredCompactColumn: .constant(.sidebar)) {
            Sidebar(selected: $selected, model: .init(sceneModel.addressBook))
                .navigationDestination(for: NavigationDestination.self, destination: destinationView(_:))
        } detail: {
            let destination = selected?.destination ?? .lists
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
