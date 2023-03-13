//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/10/23.
//

import SwiftUI

struct SplitView: View {
    @EnvironmentObject
    var appModel: AppModel
    
    @State
    var selected: NavigationItem? = .pinnedAddress("app")
    
    var body: some View {
        NavigationSplitView {
            Sidebar(selected: $selected, model: .init(appModel: appModel))
        } content: {
            appModel.destinationConstructor.destination(selected?.destination)
                .navigationDestination(for: NavigationDestination.self, destination: appModel.destinationConstructor.destination(_:))
        } detail: {
            appModel.destinationConstructor.destination(.address("app"))
        }

    }
}
