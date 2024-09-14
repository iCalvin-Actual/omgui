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
    @Environment(\.viewContext)
    var viewContext
    
    @State
    var shareURL: URL?
    @State
    var presentURL: URL?
    
    @State
    var expandBio: Bool = false
    
    init(fetcher: StatusDataFetcher) {
        self.fetcher = fetcher
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                if viewContext != .profile {
                    AddressSummaryHeader(expandBio: $expandBio, addressBioFetcher: sceneModel.addressSummary(fetcher.address).bioFetcher)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Material.thin)
                        .cornerRadius(10)
                        .padding()
                        .background(Color.clear)
                }
                if let model = fetcher.result {
                    StatusRowView(model: model)
                        .environment(\.viewContext, ViewContext.detail)
                        .padding(.horizontal)
                } else if fetcher.loading {
                    LoadingView()
                        .padding()
                } else {
                    LoadingView()
                        .padding()
                        .task { [fetcher] in
                            await fetcher.updateIfNeeded(forceReload: true)
                        }
                }
                if let items = fetcher.result?.imageLinks, !items.isEmpty {
                    imageSection(items)
                        .padding(.horizontal)
                }
                if let items = fetcher.result?.linkedItems, !items.isEmpty {
                    linksSection(items)
                        .padding(.horizontal)
                }
                Spacer()
            }
        }
        .navigationTitle("")
        .toolbar {
            if viewContext != .profile {
                ToolbarItem(placement: .topBarLeading) {
                    AddressNameView(fetcher.address, suffix: "/status")
                }
            }
        }
        .onChange(of: fetcher.id, {
            Task { [fetcher] in
                await fetcher.updateIfNeeded(forceReload: true)
            }
        })
        .task { [fetcher] in
            await fetcher.updateIfNeeded(forceReload: true)
        }
        .sheet(item: $presentURL, content: { url in
            SafariView(url: url)
                .ignoresSafeArea(.container, edges: .all)
        })
        .environment(\.viewContext, ViewContext.detail)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let url = fetcher.result?.shareURLs.first?.content {
                    ShareLink(item: url)
                }
            }
        }
    }
    
    @ViewBuilder
    private func imageSection(_ items: [SharePacket]) -> some View {
        Text("images")
            .font(.title2)
        LazyVStack {
            ForEach(items) { item in
                linkPreviewBuilder(item)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    @ViewBuilder
    private func linksSection(_ items: [SharePacket]) -> some View {
        Text("links")
            .font(.subheadline)
        
        LazyVStack {
            ForEach(items) { item in
                linkPreviewBuilder(item)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    @ViewBuilder
    private func linkPreviewBuilder(_ item: SharePacket) -> some View {
        Button {
            guard item.content.scheme?.contains("http") ?? false else {
                UIApplication.shared.open(item.content)
                return
            }
            withAnimation {
                presentURL = item.content
            }
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    if !item.name.isEmpty {
                        Text(item.name)
                            .font(.subheadline)
                            .bold()
                            .fontDesign(.rounded)
                    }
                    
                    Text(item.content.absoluteString)
                        .font(.caption)
                        .fontDesign(.monospaced)
                }
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                
                Spacer()
                
                if item.content.scheme?.contains("http") ?? false {
                    ZStack {
                        RemoteHTMLContentView(activeAddress: fetcher.address, startingURL: item.content, activeURL: $presentURL, scrollEnabled: .constant(false))
                            
                        LinearGradient(
                            stops: [
                                .init(color: .lolBackground, location: 0.1),
                                .init(color: .clear, location: 0.5)
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    }
                    .frame(width: 144, height: 144)
                    .mask {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                    }
                }
            }
            .foregroundColor(.primary)
            .padding(4)
            .background(Material.thin)
            .mask {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
            }
        }
    }
}

#Preview {
    let sceneModel = SceneModel.sample
    StatusView(fetcher: StatusDataFetcher(id: "", from: "app", interface: sceneModel.interface, db: sceneModel.database))
        .environment(sceneModel)
}
