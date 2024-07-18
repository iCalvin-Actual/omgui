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
                    if let draftPoster = fetcher.draftPoster {
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
                                    draftPoster.deletePresented()
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
                withAnimation(nil) {
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
    
    @ObservedObject
    var fetcher: AddressPasteDataFetcher
    
    var body: some View {
        NamedItemView(fetcher: fetcher, mainContent: mainContent, draftContent: draftContent)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if let name = fetcher.model?.name {
                        ThemedTextView(text: "/\(name)")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        if let content = fetcher.model?.content {
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
                        if let shareItem = fetcher.model?.shareURLs.first {
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
    }
    
    @ViewBuilder
    var mainContent: some View {
        VStack(alignment: .leading) {
            Group {
                Text("\(fetcher.addressName).paste.lol/")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color.accentColor)
                +
                Text(fetcher.model?.name ?? fetcher.title)
                    .font(.title3)
                    .foregroundStyle(Color.primary)
            }
            .fontDesign(.monospaced)
            .padding(.top)
            .padding(.horizontal)
            
            ScrollView {
                Text(fetcher.model?.content ?? "")
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
        if let poster = fetcher.draftPoster {
            PasteDraftView(draftFetcher: poster)
        } else {
            EmptyView()
        }
    }
}
