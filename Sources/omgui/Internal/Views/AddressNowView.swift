//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftData
import SwiftUI

struct AddressNowView: View {
    @Environment(SceneModel.self)
    var sceneModel
    
    let address: AddressName
    
    @Query
    var nows: [AddressNowModel]
    var now: AddressNowModel? {
        nows.first(where: { $0.owner == address })
    }
    
    var body: some View {
        htmlBody
            .onAppear {
                Task {
                    try await sceneModel.fetchNow(address)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ThemedTextView(text: address.addressDisplayString + ".now")
                }
            }
    }
    
    @ViewBuilder
    var htmlBody: some View {
        if let html = now?.html {
            if html.isEmpty {
                ThemedTextView(text: "no /now page")
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
    
    @ViewBuilder
    var markdownBody: some View {
        MarkdownContentView(content: now?.content ?? "")
    }
}
