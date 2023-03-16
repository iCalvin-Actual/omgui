//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct TabBar: View {
    @EnvironmentObject
    var sceneModel: SceneModel
    
    @State
    var selected: NavigationItem?
    
    let tabModel: TabBarModel = .init()
    
    var body: some View {
        TabView {
            ForEach(tabModel.tabs) { item in
                NavigationStack {
                    sceneModel.destinationConstructor.destination(item.destination)
                        .navigationDestination(for: NavigationDestination.self, destination: sceneModel.destinationConstructor.destination(_:))
                }
                .tag(item)
                .tabItem {
                    item.label
                }
            }
        }
    }
}
