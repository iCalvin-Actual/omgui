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
        MarkdownContentView(content: fetcher.content)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ThemedTextView(text: AddressContent.now.externalUrlString(for: fetcher.addressName), font: .callout)
                        .fontDesign(.monospaced)
                }
            }
    }
}
