//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftData
import SwiftUI

struct AddressProfileView: View {
    @Environment(SceneModel.self)
    var sceneModel
    
    let address: AddressName
    
    @Query
    var profiles: [AddressProfileModel]
    var profile: AddressProfileModel? {
        profiles.first(where: { $0.owner == address })
    }
    
    var body: some View {
        htmlBody
            .onAppear {
                Task {
                    try await sceneModel.fetchConstructor.fetchProfile(address)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ThemedTextView(text: address.addressDisplayString)
                }
            }
    }
    
    @ViewBuilder
    var htmlBody: some View {
        if let html = profile?.content {
            if html.isEmpty {
                ThemedTextView(text: "no public profile")
                    .padding()
            } else {
                HTMLFetcherView(
                    activeAddress: address,
                    htmlContent: html,
                    baseURL: nil
                )
            }
        } else {
            VStack {
                LoadingView()
                Spacer()
            }
        }
    }
}
