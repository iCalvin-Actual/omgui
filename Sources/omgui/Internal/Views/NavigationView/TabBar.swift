//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct TabBar: View {
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    
    @SceneStorage("app.tab.selected")
    var selected: NavigationItem?
    
    let tabModel: SidebarModel
    
    init(sceneModel: SceneModel) {
        self.tabModel = .init(sceneModel: sceneModel)
    }
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .phone || horizontalSizeClass == .compact {
            compactTabBar
                .onAppear{
                    if selected == nil {
                        selected = .search
                    }
                }
        } else {
            regularTabBar
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        LogoView()
                    }
                }
        }
    }
    
    @ViewBuilder
    var compactTabBar: some View {
        TabView(selection: $selected) {
            ForEach(tabModel.tabs) { item in
                Tab(item.displayString, systemImage: item.iconName, value: item) {
                    NavigationStack {
                        sceneModel.destinationConstructor.destination(item.destination)
                            .navigationDestination(for: NavigationDestination.self, destination: sceneModel.destinationConstructor.destination(_:))
                            .navigationTitle("")
                    }
                }
                .hidden(UIDevice.current.userInterfaceIdiom != .phone || horizontalSizeClass != .compact)
            }
        }
    }
    
    @ViewBuilder
    var regularTabBar: some View {
        TabView(selection: $selected) {
            Tab(NavigationItem.search.displayString, systemImage: NavigationItem.search.iconName, value: NavigationItem.search, role: .search) {
                NavigationStack {
                    sceneModel.destinationConstructor.destination(NavigationItem.search.destination)
                        .navigationDestination(for: NavigationDestination.self, destination: sceneModel.destinationConstructor.destination(_:))
                        .navigationTitle("")
                }
            }

            ForEach(tabModel.sections) { section in
                TabSection(section.displayName) {
                    ForEach(tabModel.items(for: section)) { item in
                        Tab(item.displayString, systemImage: item.iconName, value: item, role: item == .search ? .search : nil) {
                            NavigationStack {
                                sceneModel.destinationConstructor.destination(item.destination)
                                    .navigationDestination(for: NavigationDestination.self, destination: sceneModel.destinationConstructor.destination(_:))
                                    .navigationTitle("")
                            }
                        }
                        
                    }
                }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}
