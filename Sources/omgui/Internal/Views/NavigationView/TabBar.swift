//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

@available(iOS 18.0, *)
struct TabBar: View {
    static func usingRegularTabBar(sizeClass: UserInterfaceSizeClass?, width: CGFloat? = nil) -> Bool {
        guard UIDevice.current.userInterfaceIdiom != .phone && (sizeClass ?? .regular) != .compact else {
            return false
        }
        if let width {
            return width > 330
        }
        return true
    }
    
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
        if !Self.usingRegularTabBar(sizeClass: horizontalSizeClass) {
            compactTabBar
                .toolbarColorScheme(.light, for: .tabBar)
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
                    tabContent(item.destination)
                }
                .hidden(Self.usingRegularTabBar(sizeClass: horizontalSizeClass))
            }
        }
    }
    
    @ViewBuilder
    var regularTabBar: some View {
        TabView(selection: $selected) {
            Tab(NavigationItem.search.displayString, systemImage: NavigationItem.search.iconName, value: NavigationItem.search, role: .search) {
                tabContent(NavigationItem.search.destination)
            }

            ForEach(tabModel.sections) { section in
                TabSection(section.displayName) {
                    ForEach(tabModel.items(for: section)) { item in
                        Tab(item.displayString, systemImage: item.iconName, value: item, role: item == .search ? .search : nil) {
                            tabContent(item.destination)
                        }
                        
                    }
                }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
    
    @ViewBuilder
    func tabContent(_ destination: NavigationDestination) -> some View {
        NavigationStack {
            sceneModel.destinationConstructor.destination(destination)
                .navigationDestination(for: NavigationDestination.self, destination: sceneModel.destinationConstructor.destination(_:))
                .navigationTitle("")
        }
    }
}

#Preview {
    if #available(iOS 18.0, *) {
        let sceneModel = SceneModel.sample
        TabBar(sceneModel: .sample)
            .environment(sceneModel)
            .environment(AccountAuthDataFetcher(authKey: nil, client: .sample, interface: SampleData()))
    } else {
        Text("Not supported on iOS 17")
    }
}
