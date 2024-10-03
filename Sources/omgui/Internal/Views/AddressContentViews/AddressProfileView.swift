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
    var draftPoster: ProfileMarkdownDraftPoster?
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
                        if let draft = draftFetcher.results.first {
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
                                    createPoster(draft)
                                } label: {
                                    Label(title: {
                                        Text("resume draft")
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
            .sheet(item: $draftPoster, onDismiss: {
                Task { @MainActor [fetcher] in
                    await fetcher.updateIfNeeded(forceReload: true)
                }
            }, content: { poster in
                NavigationStack {
                    AddressProfileEditorView(poster, basedOn: selectedDraft)
                }
                .presentationDetents([.medium, .large])
            })
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
    @Environment(\.dismiss)
    var dismiss
    
    @StateObject
    var draftPoster: ProfileMarkdownDraftPoster
    
    var selectedDraft: ProfileMarkdown.Draft?
    
    @State
    var content: String = ""
    
    @State
    var confirmReset: Bool = false
    
    var hasChanges: Bool {
        draftPoster.originalDraft?.content != content
    }
    
    init(_ draftPoster: ProfileMarkdownDraftPoster, basedOn: ProfileMarkdown.Draft? = nil) {
        self._draftPoster = .init(wrappedValue: draftPoster)
        self.selectedDraft = basedOn
        self._content = .init(initialValue: draftPoster.originalDraft?.content ?? "")
    }
    
    var body: some View {
        TextEditor(text: $content)
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(12)
            .padding([.top, .horizontal])
            .background(NavigationDestination.editWebpage(draftPoster.address).gradient)
            .interactiveDismissDisabled()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if hasChanges {
                            confirmReset = true
                        } else {
                            dismiss()
                        }
                    } label: {
                        Label(title: {
                            Text("close")
                        }) {
                            Image(systemName: "xmark")
                        }
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        applyContent()
                        Task { @MainActor in
                            try? await draftPoster.saveDraft()
                        }
                    } label: {
                        Label(title: {
                            Text("stash")
                        }) {
                            Image(systemName: hasChanges ? "arrow.up.bin.fill" : "arrow.up.bin" )
                        }
                    }
                    .disabled(!hasChanges)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        applyContent()
                        Task { @MainActor in
                            await draftPoster.perform()
                        }
                    } label: {
                        Label(title: {
                            Text("submit")
                        }) {
                            Image(systemName: "arrow.up.forward.app.fill")
                        }
                    }
                }
            }
            .confirmationDialog("do you want to save your changes as a draft?", isPresented: $confirmReset) {
                
                Button(role: .destructive) {
                    dismiss()
                } label: {
                    Text("discard changes")
                }
                
                Button {
                    applyContent()
                    Task { @MainActor in
                        try? await draftPoster.saveDraft()
                    }
                } label: {
                    Text("save draft")
                }
                
                Button(role: .cancel) {
                    confirmReset = false
                } label: {
                    Text("nevermind")
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
