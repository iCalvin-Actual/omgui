//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct AddressNowView: View {
    @ObservedObject
    var fetcher: AddressNowDataFetcher
    
    var body: some View {
        htmlBody
            .task { [fetcher] in
                await fetcher.perform()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    AddressNameView(fetcher.address, path: "now")
                }
            }
    }
    
    @ViewBuilder
    var htmlBody: some View {
        if let html = fetcher.result?.html {
            HTMLFetcherView(
                fetcher: fetcher,
                activeAddress: fetcher.address,
                htmlContent: html,
                baseURL: nil
            )
        } else {
            VStack {
                if fetcher.loading {
                    LoadingView()
                } else {
                    ThemedTextView(text: "no /now page")
                        .padding()
                }
                Spacer()
            }
        }
    }
}
