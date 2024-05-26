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
    
    @State
    var presentedURL: URL? = nil
    
    var body: some View {
        htmlBody
            .frame(maxHeight: .infinity)
            .sheet(item: $presentedURL, content: { url in
                SafariView(url: url)
                    .ignoresSafeArea(.all, edges: .bottom)
            })
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ThemedTextView(text: fetcher.addressName.addressDisplayString + ".now")
                }
            }
    }
    
    @ViewBuilder
    var htmlBody: some View {
        if let html = fetcher.html {
            HTMLContentView(activeURL: $presentedURL, htmlContent: html)
        } else if fetcher.loading {
            ThemedTextView(text: "Loading")
        } else {
            ThemedTextView(text: "No Now page")
        }
    }
    
    @ViewBuilder
    var markdowyBody: some View {
        MarkdownContentView(source: fetcher, content: fetcher.content)
    }
}
