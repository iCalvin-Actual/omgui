//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 4/26/23.
//

import SwiftUI

struct NamedItemView<N: NamedDraftable, M: View, D: View>: View {
    @Environment(\.dismiss)
    var dismiss
    @Environment(\.horizontalSizeClass)
    var sizeClass
    
    @Environment(\.viewContext)
    var context: ViewContext
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    @StateObject
    var fetcher: NamedItemDataFetcher<N>
    
    @State
    var showDraft: Bool = false
    @State
    var detent: PresentationDetent = .draftDrawer
    
    @State
    var draftResult: N?
    
    let mainContent: M
    let draftContent: D
    
    var body: some View {
        mainContent
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if fetcher.draftPoster != nil {
                        Menu {
                            Button {
                                withAnimation {
                                    if detent == .large {
                                        detent = .draftDrawer
                                    } else if showDraft {
                                        detent = .large
                                    } else if !showDraft {
                                        detent = .medium
                                        showDraft = true
                                    } else {
                                        showDraft = false
                                        detent = .draftDrawer
                                    }
                                }
                            } label: {
                                Text("edit")
                            }
                            Menu {
                                Button(role: .destructive) {
                                    Task {
                                        try await fetcher.deleteIfPossible()
                                    }
                                } label: {
                                    Text("confirm")
                                }
                            } label: {
                                Label {
                                    Text("delete")
                                } icon: {
                                    Image(systemName: "trash")
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .onReceive(fetcher.$model, perform: { model in
                withAnimation {
                    let address = fetcher.addressName
                    guard sceneModel.accountModel.myAddresses.contains(address) else {
                        showDraft = false
                        return
                    }
                    if model == nil && fetcher.title.isEmpty {
                        detent = .large
                        showDraft = true
                    } else if model != nil {
                        detent = .draftDrawer
                        showDraft = true
                    } else {
                        print("Stop")
                    }
                }
            })
            .onChange(of: draftResult, { oldValue, newValue in
                guard let newValue else {
                    return
                }
                fetcher.model = newValue
                detent = .draftDrawer
                showDraft = true
                Task { await fetcher.perform() }
            })
            .sheet(
                isPresented: $showDraft,
                onDismiss: {
                    if fetcher.model == nil {
                        dismiss()
                    }
                },
                content: {
                    draftContent
                        .presentationDetents(
                            fetcher.model == nil ? [
                                .draftDrawer,
                                .large
                            ] : [
                                .draftDrawer,
                                .medium,
                                .large
                            ],
                            selection: $detent
                        )
                        .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                }
            )
    }
}

struct PasteView: View {
    @Environment(\.dismiss)
    var dismiss
    @Environment(\.horizontalSizeClass)
    var sizeClass
    
    @Environment(\.viewContext)
    var context: ViewContext
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    @ObservedObject
    var fetcher: AddressPasteDataFetcher
    
    @State
    var showDraft: Bool = false
    @State
    var detent: PresentationDetent = .draftDrawer
    
    var body: some View {
        mainContent
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if let name = fetcher.result?.name {
                        ThemedTextView(text: "/\(name)")
                    }
                }
//                ToolbarItem(placement: .topBarTrailing) {
//                    if fetcher.draftPoster != nil {
//                        Menu {
//                            Button {
//                                withAnimation {
//                                    if detent == .large {
//                                        detent = .draftDrawer
//                                    } else if showDraft {
//                                        detent = .large
//                                    } else if !showDraft {
//                                        detent = .medium
//                                        showDraft = true
//                                    } else {
//                                        showDraft = false
//                                        detent = .draftDrawer
//                                    }
//                                }
//                            } label: {
//                                Text("edit")
//                            }
//                            Menu {
//                                Button(role: .destructive) {
//                                    Task {
//                                        try await fetcher.deleteIfPossible()
//                                    }
//                                } label: {
//                                    Text("confirm")
//                                }
//                            } label: {
//                                Label {
//                                    Text("delete")
//                                } icon: {
//                                    Image(systemName: "trash")
//                                }
//                            }
//                        } label: {
//                            Image(systemName: "ellipsis.circle")
//                        }
//                    }
//                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        if let content = fetcher.result?.content {
                            ShareLink(item: content)
                            Button(action: {
                                UIPasteboard.general.string = content
                            }, label: {
                                Label(
                                    title: { Text("Copy Content") },
                                    icon: { Image(systemName: "doc.on.doc") }
                                )
                            })
                        }
                        Divider()
                        if let shareItem = fetcher.result?.shareURLs.first {
                            ShareLink(shareItem.name, item: shareItem.content)
                            Button(action: {
                                UIPasteboard.general.string = shareItem.content.absoluteString
                            }, label: {
                                Label(
                                    title: { Text("Copy URL") },
                                    icon: { Image(systemName: "link") }
                                )
                            })
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .onReceive(fetcher.$result, perform: { model in
                withAnimation {
                    let address = model?.addressName ?? ""
                    guard !address.isEmpty, sceneModel.accountModel.myAddresses.contains(address) else {
                        showDraft = false
                        return
                    }
                    if model == nil && fetcher.title.isEmpty {
                        detent = .large
                        showDraft = true
                    } else if model != nil {
                        detent = .draftDrawer
                        showDraft = true
                    } else {
                        print("Stop")
                    }
                }
            })
    }
    
    @ViewBuilder
    var mainContent: some View {
        VStack(alignment: .leading) {
            Group {
                Text("\(fetcher.address).paste.lol/")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color.accentColor)
                +
                Text(fetcher.result?.name ?? fetcher.title)
                    .font(.title3)
                    .foregroundStyle(Color.primary)
            }
            .fontDesign(.monospaced)
            .padding(.top)
            .padding(.horizontal)
            
            ScrollView {
                Text(fetcher.result?.content ?? "")
                    .textSelection(.enabled)
                    .font(.body)
                    .fontDesign(.monospaced)
                    .padding(.vertical, 4)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(4)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    var draftContent: some View {
//        if let poster = fetcher.draftPoster {
//            PasteDraftView(draftFetcher: poster)
//        } else {
            EmptyView()
//        }
    }
}
