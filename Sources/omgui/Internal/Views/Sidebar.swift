//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct Sidebar: View {
    @EnvironmentObject
    var appModel: AppModel
    
    @Binding
    var selected: NavigationItem?
    
    var sidebarModel: SidebarModel?
    
    init(selected: Binding<NavigationItem?>, model: SidebarModel) {
        self._selected = selected
        self.sidebarModel = model
    }
    
    var body: some View {
        if let model = sidebarModel {
            VStack {
                List(model.sections, selection: $selected) { section in
                    let items = model.items(for: section)
                    if !items.isEmpty {
                        Section {
                            ForEach(items) { item in
                                item.sidebarView
                                    .contextMenu(menuItems: {
                                        item.contextMenu(with: appModel)
                                    })
                            }
                        } header: {
                            HStack {
                                Text(section.displayName)
                                    .fontDesign(.monospaced)
                                    .font(.subheadline)
                                    .bold()
                                Spacer()
                            }
                        }
                    }
                }
                Spacer()
            }
        }
    }
}
