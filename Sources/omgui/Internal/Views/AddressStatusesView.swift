//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct AddressStatusesView: View {
    @ObservedObject
    var fetcher: StatusLogDataFetcher
    
    @ObservedObject
    var bioFetcher: AddressBioDataFetcher
    
    let context: ViewContext
    
    var body: some View {
        VStack(alignment: .leading) {
            AddressBioView(fetcher: bioFetcher)
            StatusList(fetcher: fetcher, context: .profile)
        }
        .toolbar {       
            ToolbarItem(placement: .topBarLeading) {
                ThemedTextView(text: bioFetcher.address.addressDisplayString + ".statuses")
            }
        }
    }
}
