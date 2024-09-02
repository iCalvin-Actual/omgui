//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 9/2/24.
//

import SwiftUI


struct AboutView: View {
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    @State var presented: URL?
    
    var body: some View {
        RemoteHTMLContentView(activeAddress: sceneModel.addressBook.actingAddress, startingURL: URL(string: "https://home.omg.lol/referred-by/app")!, activeURL: $presented, scrollEnabled: .constant(true))
            .sheet(item: $presented, content: { url in
                SafariView(url: url)
                    .presentationSizing(.page)
                    .ignoresSafeArea(.all, edges: .bottom)
            })
    }
}
