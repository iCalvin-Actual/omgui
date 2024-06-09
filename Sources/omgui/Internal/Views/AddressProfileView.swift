//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct AddressProfileView: View {
    @ObservedObject
    var fetcher: AddressProfileDataFetcher
    
    var body: some View {
        htmlBody
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ThemedTextView(text: fetcher.addressName.addressDisplayString)
                }
            }
    }
    
    @ViewBuilder
    var htmlBody: some View {
        if let html = fetcher.html {
            HTMLFetcherView(
                fetcher: fetcher,
                activeAddress: fetcher.addressName,
                htmlContent: html,
                baseURL: nil
            )
        } else {
            VStack {
                if fetcher.loading {
                    LoadingView()
                } else {
                    ThemedTextView(text: "no public profile")
                        .padding()
                }
                Spacer()
            }
        }
    }
}
