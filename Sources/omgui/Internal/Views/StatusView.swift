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
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    var status: StatusModel?
    
    @ObservedObject
    var feedFetcher: StatusLogDataFetcher
    
    @State
    var shareURL: URL?
    
    init(fetcher: StatusDataFetcher, status: StatusModel? = nil) {
        self.fetcher = fetcher
        self.feedFetcher = StatusLogDataFetcher(addresses: [fetcher.address], interface: fetcher.interface)
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                if let model = fetcher.status ?? status {
                    StatusRowView(model: model)
                        .padding()
                } else if fetcher.loading {
                    LoadingView()
                }
                Spacer()
            }
        }
        .environment(\.viewContext, ViewContext.detail)
        .toolbar {
//            ToolbarItem(placement: .topBarLeading) {
//                ThemedTextView(text: ".status")
//            }
            ToolbarItem(placement: .topBarTrailing) {
                if let url = fetcher.status?.shareURLs.first?.content {
                    ShareLink(item: url)
                }
            }
        }
    }
}
