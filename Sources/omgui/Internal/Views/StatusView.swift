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
    @State
    var presentURL: URL?
    
    init(fetcher: StatusDataFetcher, status: StatusModel? = nil) {
        self.fetcher = fetcher
        self.feedFetcher = StatusLogDataFetcher(addresses: [fetcher.address], interface: fetcher.interface)
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                if let model = fetcher.status ?? status {
                    StatusRowView(model: model)
                        .padding()
                } else if fetcher.loading {
                    LoadingView()
                }
                if let items = fetcher.status?.linkedItems, !items.isEmpty {
                    linksSection(items)
                        .padding(.horizontal)
                }
                Spacer()
            }
        }
        .sheet(item: $presentURL, content: { url in
            SafariView(url: url)
                .ignoresSafeArea(.all, edges: .bottom)
        })
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
    
    @ViewBuilder
    private func linksSection(_ items: [SharePacket]) -> some View {
        Text("links")
            .font(.title2)
        
        GeometryReader { proxy in
            Grid {
                GridRow {
                    ForEach(items.enumerated().filter({ !$0.offset.isMultiple(of: 2) }).map({ $0.element })) { item in
                        linkPreviewBuilder(item)
                    }
                }
                .frame(maxWidth: proxy.percentageWidth(0.5))
                GridRow {
                    ForEach(items.enumerated().filter({ $0.offset.isMultiple(of: 2) }).map({ $0.element })) { item in
                        linkPreviewBuilder(item)
                    }
                }
                .frame(maxWidth: proxy.percentageWidth(0.5))
            }
        }
    }
    
    @ViewBuilder
    private func linkPreviewBuilder(_ item: SharePacket) -> some View {
        Button {
            withAnimation {
                presentURL = item.content
            }
        } label: {
            VStack(alignment: .leading) {
                if !item.name.isEmpty {
                    Text(item.name)
                        .font(.headline)
                        .fontDesign(.rounded)
                }
                
                Text(item.content.absoluteString)
                    .font(.caption)
                    .fontDesign(.monospaced)
                    .multilineTextAlignment(.leading)
                
                ZStack {
                    RemoteHTMLContentView(activeAddress: fetcher.address, startingURL: item.content, activeURL: $presentURL)
                    LinearGradient(
                        stops: [
                            .init(color: .lolBackground, location: 0.1),
                            .init(color: .clear, location: 0.5)
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                }
                .frame(height: 144)
                .mask {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                }
            }
            .foregroundColor(.primary)
            .padding(4)
            .background(Color.lolBackground)
            .mask {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
            }
        }
    }
}
