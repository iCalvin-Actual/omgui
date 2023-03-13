//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct TabBar: View {
    @EnvironmentObject
    var appModel: AppModel
    
    @State
    var selected: NavigationItem?
    
    let tabModel: TabBarModel = .init()
    
    var body: some View {
        TabView(selection: $selected) {
            ForEach(tabModel.tabs) { item in
                NavigationStack {
                    appModel.destinationConstructor.destination(item.destination)
                        .navigationDestination(for: NavigationDestination.self, destination: appModel.destinationConstructor.destination(_:))
                }
                .tag(item)
                .tabItem {
                    item.label
                }
            }
        }
    }
}
