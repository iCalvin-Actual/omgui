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
    
    @ObservedObject
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
                                    Task { @MainActor [fetcher] in
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
//            .onReceive(fetcher.$model, perform: { model in
//                withAnimation {
//                    let address = fetcher.addressName
//                    guard sceneModel.myAddresses.contains(address) else {
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
            .onChange(of: draftResult, { oldValue, newValue in
                guard let newValue else {
                    return
                }
                fetcher.model = newValue
                detent = .draftDrawer
                showDraft = true
                Task { [fetcher] in
                    await fetcher.perform()
                }
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
    var viewContext
    
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
            .onChange(of: fetcher.address, {
                Task { [fetcher] in
                    await fetcher.updateIfNeeded(forceReload: true)
                }
            })
            .onChange(of: fetcher.title, {
                Task { [fetcher] in
                    await fetcher.updateIfNeeded(forceReload: true)
                }
            })
            .task { [fetcher] in
                await fetcher.updateIfNeeded(forceReload: true)
            }
            .toolbar {
                if viewContext != .profile {
                    ToolbarItem(placement: .topBarLeading) {
                        AddressNameView(fetcher.address, suffix: "/pastebin")
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
                    if let pasteURL = fetcher.result?.pasteURL {
                        Menu {
                            ShareLink("share paste", item: pasteURL)
                            Divider()
                            Button(action: {
                                UIPasteboard.general.string = pasteURL.absoluteString
                            }, label: {
                                Label(
                                    title: { Text("copy paste") },
                                    icon: { Image(systemName: "doc.on.clipboard") }
                                )
                            })
                            if let shareItem = fetcher.result?.content {
                                Button(action: {
                                    UIPasteboard.general.string = shareItem
                                }, label: {
                                    Label(
                                        title: { Text("copy paste content") },
                                        icon: { Image(systemName: "text.alignleft") }
                                    )
                                })
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .onChange(of: fetcher.result, initial: false) { _, model in
                withAnimation {
                    let address = model?.addressName ?? ""
                    guard !address.isEmpty, sceneModel.addressBook.myAddresses.contains(address) else {
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
            }
    }
    
    @ViewBuilder
    var mainContent: some View {
        VStack(alignment: .leading) {
            if context != .profile {
                HStack(alignment: .bottom) {
                    AddressIconView(address: fetcher.address)
                    Text("/\(fetcher.result?.name ?? fetcher.title)")
                        .font(.title2)
                        .fontDesign(.serif)
                        .foregroundStyle(Color.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Material.thin)
                .cornerRadius(10)
                .padding()
                .background(Color.clear)
            }
            
            ScrollView {
                if let model = fetcher.result {
                    MarkdownContentView(source: model, content: model.content)
                        .padding(.vertical, 4)
                        .padding(.horizontal)
                } else {
                    Text(fetcher.result?.content ?? "")
                        .textSelection(.enabled)
                        .font(.body)
                        .fontDesign(.rounded)
                        .padding(.vertical, 4)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
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
