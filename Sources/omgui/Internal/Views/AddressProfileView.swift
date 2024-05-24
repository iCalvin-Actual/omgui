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
        HTMLContentView(activeURL: $presentedURL, htmlContent: fetcher.html)
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
}
