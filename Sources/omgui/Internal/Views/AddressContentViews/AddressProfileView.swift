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
    var fetcher: AddressProfileDataFetcher
    
    @State
    var draftPoster: MDDraftPoster<AddressProfile>?
    @State
    var selectedDraft: AddressProfile.Draft?
    
    init(fetcher: AddressProfileDataFetcher) {
        self.fetcher = fetcher
    }
    
    var body: some View {
        htmlBody
            .onChange(of: fetcher.addressName) {
                Task { [fetcher] in
                    await fetcher.updateIfNeeded(forceReload: true)
                }
            }
            .onAppear {
                Task { @MainActor [fetcher] in
                    await fetcher.updateIfNeeded(forceReload: true)
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
                if sceneModel.addressBook.myAddresses.contains(fetcher.addressName) {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            draftPoster = .init(result.owner, draftItem: result.asDraft, interface: fetcher.interface, credential: fetcher.credential ?? "")
                        } label: {
                            Label(title: {
                                Text("edit")
                            }, icon: {
                                Image(systemName: "pencil")
                            })
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if let url = fetcher.result?.primaryURL {
                        ShareLink(item: url.content)
                    }
                }
            }
            .sheet(item: $draftPoster) {
                print("Save as draft")
            } content: { poster in
                NavigationStack {
                    AddressProfileEditorView(poster, basedOn: $selectedDraft)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button {
                                    showDrafts = true
                                } label: {
                                    Label(title: {
                                        Text("drafts")
                                    }, icon: {
                                        Image(systemName: "list.dash")
                                    })
                                }
                            }
                        }
                }
                .sheet(isPresented: $showDrafts, content: {
                    Text("Drafts lists")
                })
                .presentationDetents([.medium, .large])
            }

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
}

struct AddressProfileEditorView: View {
    @StateObject
    var draftPoster: MDDraftPoster<AddressProfile>
    
    var selectedDraft: Binding<AddressProfile.Draft?>
    
    init(_ draftPoster: MDDraftPoster<AddressProfile>, basedOn: Binding<AddressProfile.Draft?>) {
        self._draftPoster = .init(wrappedValue: draftPoster)
        self.selectedDraft = basedOn
    }
    var body: some View {
        TextEditor(text: $draftPoster.draft.content)
    }
}
