//
//  AccountBar.swift
//  My App
//
//  Created by Calvin Chestnut on 2/12/23.
//

import SwiftUI
import Foundation

@available(iOS 16.1, *)
struct AccountBar: View {
    @EnvironmentObject
    var appModel: AppModel
    
    @EnvironmentObject
    var model: SceneModel
    
    var body: some View {
        HStack {
            AccountView(showAccount: $model.showAccount, activeAddress: model.actingAddress)
                .keyboardShortcut("t", modifiers: [.command, .shift])
            
            Spacer()
            
//            Button(action: {
//                withAnimation {
//                    model.showingSettings.toggle()
//                }
//            }, label: {
//                Label("", systemImage: "gear")
//            })
//            .keyboardShortcut(",", modifiers: [.command])
        }
        .padding()
    }
}
