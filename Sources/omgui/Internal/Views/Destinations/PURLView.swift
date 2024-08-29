//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 4/26/23.
//

import SwiftUI

struct PURLView: View {
    @Environment(\.dismiss)
    var dismiss
    @Environment(\.horizontalSizeClass)
    var sizeClass
    
    @Environment(\.viewContext)
    var context: ViewContext
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    let fetcher: AddressPURLDataFetcher
    
    @State
    var showDraft: Bool = false
    @State
    var detent: PresentationDetent = .draftDrawer
    
    @State
    var presented: URL? = nil
    
    var body: some View {
        LoadingView()
//        content
//            .toolbar {
//                ToolbarItem(placement: .topBarLeading) {
//                    if let name = fetcher.result?.name {
//                        ThemedTextView(text: "/\(name)")
//                    }
//                }
////                ToolbarItem(placement: .topBarTrailing) {
////                    if fetcher.draftPoster != nil {
////                        Menu {
////                            Button {
////                                withAnimation {
////                                    if detent == .large {
////                                        detent = .draftDrawer
////                                    } else if showDraft {
////                                        detent = .large
////                                    } else if !showDraft {
////                                        detent = .medium
////                                        showDraft = true
////                                    } else {
////                                        showDraft = false
////                                        detent = .draftDrawer
////                                    }
////                                }
////                            } label: {
////                                Text("edit")
////                            }
////                            Menu {
////                                Button(role: .destructive) {
////                                    Task {
////                                        try await fetcher.deleteIfPossible()
////                                    }
////                                } label: {
////                                    Text("confirm")
////                                }
////                            } label: {
////                                Label {
////                                    Text("delete")
////                                } icon: {
////                                    Image(systemName: "trash")
////                                }
////                            }
////                        } label: {
////                            Image(systemName: "ellipsis.circle")
////                        }
////                    }
////                }
//                ToolbarItem(placement: .topBarTrailing) {
//                    Menu {
//                        if let content = fetcher.result?.content {
//                            ShareLink(item: content)
//                            Button(action: {
//                                UIPasteboard.general.string = content
//                            }, label: {
//                                Label(
//                                    title: { Text("Copy Content") },
//                                    icon: { Image(systemName: "doc.on.doc") }
//                                )
//                            })
//                        }
//                        Divider()
//                        if let shareItem = fetcher.result?.shareURLs.first {
//                            ShareLink(shareItem.name, item: shareItem.content)
//                            Button(action: {
//                                UIPasteboard.general.string = shareItem.content.absoluteString
//                            }, label: {
//                                Label(
//                                    title: { Text("Copy URL") },
//                                    icon: { Image(systemName: "link") }
//                                )
//                            })
//                        }
//                    } label: {
//                        Image(systemName: "square.and.arrow.up")
//                    }
//                }
//            }
//            .onReceive(fetcher.$result, perform: { model in
//                withAnimation {
//                    let address = model?.addressName ?? ""
//                    guard !address.isEmpty, sceneModel.addressBook.myAddresses.contains(address) else {
//                        showDraft = false
//                        return
//                    }
//                    if model == nil && fetcher.title.isEmpty {
//                        detent = .large
//                        showDraft = true
//                    } else if model != nil {
//                        detent = .draftDrawer
//                        showDraft = true
//                    } else {
//                        print("Stop")
//                    }
//                }
//            })
    }
    
    @ViewBuilder
    var draftView: some View {
//        if let poster = fetcher.draftPoster {
//            PURLDraftView(draftFetcher: poster)
//        }
        EmptyView()
    }
    
//    @ViewBuilder
//    func mainContent(_ poster: PURLDraftPoster?) -> some View {
//        if let poster {
//            content
//                .onReceive(poster.$result.dropFirst(), perform: { savedResult in
//                print("Stop here")
//            })
//        } else {
//            content
//        }
//    }
    
    @ViewBuilder
    var content: some View {
        preview
            .safeAreaInset(edge: .top) {
                overlay
            }
    }
    
    @ViewBuilder
    var preview: some View {
        if let content = fetcher.result?.content, !content.isEmpty {
            HTMLContentView(activeAddress: fetcher.address, htmlContent: nil, baseURL: URL(string: content), activeURL: $presented)
        } else {
            Spacer()
        }
    }
    
    @ViewBuilder
    var overlay: some View {
        VStack(alignment: .leading, spacing: 0) {
            if context != .profile {
                HStack(alignment: .top) {
                    Spacer()
                    AddressNameView(fetcher.address)
                    Menu {
                        AddressModel(name: fetcher.address).contextMenu(in: sceneModel)
                    } label: {
                        AddressIconView(address: fetcher.address)
                    }
                    .padding(.trailing)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Group {
                    switch sizeClass {
                    default:
                        Text("\(fetcher.address).purl.lol/")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Color.accentColor)
                        +
                        Text(fetcher.result?.name ?? fetcher.title)
                            .font(.title3)
                            .foregroundStyle(Color.primary)
                    }
                }
                .font(.system(size: 100))
                .minimumScaleFactor(0.01)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .fontDesign(.monospaced)
                .lineLimit(2)
                
                if let destination = fetcher.result?.content, destination.isEmpty {
                    Text(destination)
                        .textSelection(.enabled)
                        .font(.caption)
                        .fontDesign(.serif)
                        .lineLimit(2)
                }
            }
            .padding(.horizontal)
        }
    }
}
