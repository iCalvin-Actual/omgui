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
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ThemedTextView(text: fetcher.addressName.addressDisplayString + ".now")
                }
            }
    }
    
    @ViewBuilder
    var htmlBody: some View {
        if let html = fetcher.html {
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
    
    @ViewBuilder
    var markdowyBody: some View {
        MarkdownContentView(source: fetcher, content: fetcher.content)
    }
}
