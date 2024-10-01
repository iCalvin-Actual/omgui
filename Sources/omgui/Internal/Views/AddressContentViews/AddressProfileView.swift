//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct AddressProfileView: View {
    
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    @State
    var showEditor: Bool = false
    @State
    var showDrafts: Bool = false
    
    @ObservedObject
    var fetcher: AddressProfileHTMLDataFetcher
    @ObservedObject
    var mdFetcher: ProfileMarkdownDataFetcher
    @ObservedObject
    var draftFetcher: DraftFetcher<ProfileMarkdown>
    
    @State
    var draftPoster: MDDraftPoster<ProfileMarkdown>?
    @State
    var selectedDraft: ProfileMarkdown.Draft?
    
    init(fetcher: AddressProfileHTMLDataFetcher, mdFetcher: ProfileMarkdownDataFetcher, draftFetcher: DraftFetcher<ProfileMarkdown>) {
        self.fetcher = fetcher
        self.mdFetcher = mdFetcher
        self.draftFetcher = draftFetcher
    }
    
    var body: some View {
        htmlBody
            .onChange(of: fetcher.addressName) {
                Task { [fetcher] in
                    await fetcher.updateIfNeeded(forceReload: true)
                    await draftFetcher.updateIfNeeded(forceReload: true)
                }
            }
            .onAppear {
                Task { @MainActor [fetcher] in
                    await fetcher.updateIfNeeded(forceReload: true)
                    await draftFetcher.updateIfNeeded(forceReload: true)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    AddressNameView(fetcher.addressName)
                }
            }
    }
    
    @ViewBuilder
    var htmlBody: some View {
        if let result = fetcher.result {
            HTMLFetcherView(
                fetcher: fetcher,
                activeAddress: fetcher.addressName,
                htmlContent: result.content,
                baseURL: nil
            )
            .toolbar {
                if let markdown = mdFetcher.result, sceneModel.addressBook.myAddresses.contains(fetcher.addressName) {
                    ToolbarItem(placement: .topBarTrailing) {
                        if draftFetcher.items > 0 {
                            Menu {
                                Button {
                                    createPoster(markdown.asDraft)
                                } label: {
                                    Label(title: {
                                        Text("edit")
                                    }, icon: {
                                        Image(systemName: "pencil")
                                    })
                                }
                                Button {
                                    showDrafts = true
                                } label: {
                                    Label(title: {
                                        Text("drafts")
                                    }, icon: {
                                        Image(systemName: "arrow.up.bin.fill")
                                    })
                                }
                            } label: {
                                Label(title: {
                                    Text("edit")
                                }, icon: {
                                    Image(systemName: "pencil")
                                })
                            }
                            } else {
                            Button {
                                createPoster(markdown.asDraft)
                            } label: {
                                Label(title: {
                                    Text("edit")
                                }, icon: {
                                    Image(systemName: "pencil")
                                })
                            }
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if let url = fetcher.result?.primaryURL {
                        ShareLink(item: url.content)
                    }
                }
            }
            .sheet(item: $draftPoster) { poster in
                NavigationStack {
                    AddressProfileEditorView(poster, basedOn: $selectedDraft)
                }
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showDrafts, content: {
                draftsView(draftFetcher)
                    .presentationDetents([.medium])
                    .environment(\.horizontalSizeClass, .compact)
            })

        } else {
            VStack {
                if fetcher.loading {
                    LoadingView()
                        .padding()
                } else if fetcher.error?.localizedDescription.lowercased().contains("not found") ?? false {
                    ThemedTextView(text: "no profile")
                        .padding()
                }
                Spacer()
            }
        }
    }
    
    func createPoster(_ item: ProfileMarkdown.Draft) {
        showDrafts = false
        draftPoster = .init(fetcher.addressName, draftItem: item, interface: fetcher.interface, credential: mdFetcher.credential, addressBook: sceneModel.addressBook, db: sceneModel.database)
    }
    
    @ViewBuilder
    func draftsView(_ fetcher: DraftFetcher<ProfileMarkdown>) -> some View {
        ListView<ProfileMarkdown.Draft, EmptyView>(dataFetcher: fetcher, selectionOverride: { selected in
            createPoster(selected)
        })
    }
}

struct AddressProfileEditorView: View {
    @StateObject
    var draftPoster: MDDraftPoster<ProfileMarkdown>
    
    var selectedDraft: Binding<ProfileMarkdown.Draft?>
    
    @State
    var content: String = ""
    
    var hasChanges: Bool {
        draftPoster.originalDraft?.content != content
    }
    
    init(_ draftPoster: MDDraftPoster<ProfileMarkdown>, basedOn: Binding<ProfileMarkdown.Draft?>) {
        self._draftPoster = .init(wrappedValue: draftPoster)
        self.selectedDraft = basedOn
        self._content = .init(initialValue: draftPoster.originalDraft?.content ?? "")
    }
    var body: some View {
        TextEditor(text: $content)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        applyContent()
                        Task { @MainActor in
                            try? await draftPoster.saveDraft()
                        }
                    } label: {
                        Label(title: {
                            Text("save draft")
                        }) {
                            Image(systemName: "arrow.down.to.line")
                        }
                    }
                    .disabled(!hasChanges)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        print("Reset")
                    } label: {
                        Label(title: {
                            Text("reset")
                        }) {
                            Image(systemName: "xmark.bin")
                        }
                    }
                    .disabled(!hasChanges)
                }
            }
    }
    
    func applyContent() {
        self.draftPoster.draft.content = content
    }
    
    func resetContent() {
        content = draftPoster.originalDraft?.content ?? ""
    }
}
