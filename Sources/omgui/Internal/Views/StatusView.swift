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
    @EnvironmentObject
    var sceneModel: SceneModel
    
    @ObservedObject
    var feedFetcher: StatusLogDataFetcher
    
    @State
    var shareURL: URL?
    
    init(fetcher: StatusDataFetcher) {
        self.fetcher = fetcher
        self.feedFetcher = StatusLogDataFetcher(addresses: [fetcher.address], interface: fetcher.interface)
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                if let model = fetcher.status {
                    StatusRowView(model: model, context: .detail)
                        .padding()
                } else if fetcher.loading {
                    LoadingView()
                }
                Spacer()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ThemedTextView(text: ".status")
            }
            ToolbarItem(placement: .topBarTrailing) {
                if let url = fetcher.status?.shareURLs.first?.content {
                    ShareLink(item: url)
                }
            }
        }
    }
}
