//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/13/23.
//

import Combine
import SwiftUI

struct FollowingView: View {
    
    @ObservedObject
    var addressBook: AddressBook
    
    var requests: [AnyCancellable] = []
    
    @State
    var needsRefresh: Bool = false
    
    init(_ addressBook: AddressBook) {
        self.addressBook = addressBook
    }
    
    var body: some View {
        followingView
            .onAppear(perform: { needsRefresh = false })
    }
    
    @ViewBuilder
    var followingView: some View {
        if let followingFetcher = addressBook.followingStatusLogFetcher {
            StatusList(fetcher: followingFetcher, context: .column)
        } else {
            signedOutView
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        ThemedTextView(text: "following")
                    }
                }
        }
    }
    
    @ViewBuilder
    var signedOutView: some View {
        Text("Signed Out")
    }
}
