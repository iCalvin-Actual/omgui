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
        HTMLContentView(htmlContent: fetcher.html)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ThemedTextView(text: AddressContent.profile.externalUrlString(for: fetcher.addressName), font: .callout)
                        .fontDesign(.monospaced)
                }
            }
    }
}
