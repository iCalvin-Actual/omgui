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
            .onChange(of: fetcher.addressName) {
                Task { [fetcher] in
                    await fetcher.updateIfNeeded(forceReload: true)
                }
            }
            .task { [fetcher] in
                await fetcher.perform()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    AddressNameView(fetcher.addressName)
                }
            }
    }
    
    @ViewBuilder
    var htmlBody: some View {
        if let html = fetcher.result?.content {
            HTMLFetcherView(
                fetcher: fetcher,
                activeAddress: fetcher.addressName,
                htmlContent: html,
                baseURL: nil
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if let url = fetcher.result?.shareURLs.first?.content {
                        ShareLink(item: url)
                    }
                }
            }
        } else {
            VStack {
                if fetcher.error?.localizedDescription.lowercased().contains("not found") ?? false {
                    ThemedTextView(text: "no profile")
                        .padding()
                } else {
                    LoadingView()
                        .padding()
                }
                Spacer()
            }
        }
    }
}
