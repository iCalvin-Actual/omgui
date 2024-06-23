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
    
    @SceneStorage("app.lol.sidebar")
    var selected: NavigationItem?
    @State
    var visibility: NavigationSplitViewVisibility = .all
    
    var preferredColumn: NavigationSplitViewColumn {
        guard selected != nil else {
            return .sidebar
        }
        return .detail
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $visibility, preferredCompactColumn: .constant(preferredColumn)) {
            Sidebar(selected: $selected, model: .init(sceneModel.addressBook))
                .environment(\.viewContext, .column)
        } detail: {
            let item: NavigationItem = selected ?? (sceneModel.accountModel.signedIn ? .newStatus : .account)
            let destination = item.destination
            NavigationStack {
                destinationView(destination)
            }
            .environment(\.viewContext, sizeClass == .regular ? .detail : .column)
        }
    }
    
    @ViewBuilder
    func destinationView(_ destination: NavigationDestination? = .webpage("app")) -> some View {
            sceneModel.destinationConstructor.destination(destination)
                .navigationDestination(for: NavigationDestination.self, destination: sceneModel.destinationConstructor.destination(_:))
    }
}
