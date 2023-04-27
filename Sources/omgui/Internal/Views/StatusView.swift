//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 4/27/23.
//

import SwiftUI

struct StatusView: View {
    @ObservedObject
    var fetcher: StatusDataFetcher
    
    @ObservedObject
    var feedFetcher: StatusLogDataFetcher
    
    init(fetcher: StatusDataFetcher) {
        self.fetcher = fetcher
        self.feedFetcher = StatusLogDataFetcher(addresses: [fetcher.address], interface: fetcher.interface)
    }
    
    var body: some View {
        VStack {
            if let model = fetcher.status {
                StatusRowView(model: model, context: .detail)
            } else {
                // Loading View
                EmptyView()
            }
            Spacer()
            StatusList(fetcher: feedFetcher, context: .detail)
        }
    }
}
