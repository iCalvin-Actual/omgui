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
    var model: SceneModel
    
    @State
    var showAlert: Bool = false
    
    var body: some View {
        EmptyView()
    }
    
    var someBody: some View {
        HStack {
            AccountView(activeAddress: nil)
                .keyboardShortcut("t", modifiers: [.command, .shift])
                .disabled(true)
                .onTapGesture {
                    self.showAlert.toggle()
                }
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    model.showingSettings.toggle()
                }
            }, label: {
                Label("", systemImage: "gear")
            })
            .keyboardShortcut(",", modifiers: [.command])
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("🤷 Coming Shortly"))
        }
    }
}
