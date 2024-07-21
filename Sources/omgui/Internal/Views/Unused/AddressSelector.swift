//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 6/9/24.
//

import SwiftUI

@MainActor
struct AddressSelector: View {
    @SceneStorage("app.lol.address")
    var actingAddress: AddressName = ""
    
    @Environment(SceneModel.self)
    var sceneModel
    
    
    var body: some View {
        if sceneModel.accountModel.signedIn {
            activeAddressRow
                .padding()
        } else {
            Button {
                DispatchQueue.main.async {
                    Task {
                        await sceneModel.accountModel.authenticate()
                    }
                }
            } label: {
                Label {
                    Text("sgn in")
                } icon: {
                    Image("prami", bundle: .module)
                        .resizable()
                        .frame(width: 33, height: 33)
                }
            }
            .bold()
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.lolRandom())
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    var activeAddressRow: some View {
        ThemedTextView(text: actingAddress.addressDisplayString)
    }
}
