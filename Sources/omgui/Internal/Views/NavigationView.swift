//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 6/17/24.
//

import SwiftUI

@MainActor
struct NavigationView: View {
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    
    @Environment(SceneModel.self)
    var sceneModel
    
    var body: some View {
        SplitView()
            .environment(
                sceneModel.addressBook
            )
    }
    
    @ViewBuilder
    var appropriateNavigation: some View {
        switch horizontalSizeClass {
        case .compact:
            TabBar()
        default:
            SplitView()
        }
    }
}

#Preview {
    NavigationView()
}
