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
    
    @State
    var presentedURL: URL? = nil
    
    var body: some View {
        htmlBody
            .sheet(item: $presentedURL, content: { url in
                SafariView(url: url)
                    .ignoresSafeArea(.all, edges: .bottom)
            })
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ThemedTextView(text: fetcher.addressName.addressDisplayString)
                }
            }
    }
    
    @ViewBuilder
    var htmlBody: some View {
        if let html = fetcher.html {
            HTMLContentView(activeAddress: fetcher.addressName, htmlContent: html, activeURL: $presentedURL)
        } else {
            VStack {
                if fetcher.loading {
                    ThemedTextView(text: "loading")
                        .padding()
                } else {
                    ThemedTextView(text: "no public profile")
                        .padding()
                }
                Spacer()
            }
        }
    }
}
