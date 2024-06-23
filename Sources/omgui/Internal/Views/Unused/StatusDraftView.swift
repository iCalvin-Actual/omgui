//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 4/27/23.
//

import SwiftUI

struct StatusDraftView: View {
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    @ObservedObject
    var draftPoster: StatusDraftPoster
    @SceneStorage("app.lol.address")
    var actingAddress: AddressName = ""
    
    @State
    var expandAddresses: Bool = false
    @State
    var showPlaceholder: Bool = true
    
    enum FocusField: Hashable {
        case emoji
        case content
    }
    @FocusState
    private var focusedField: FocusField?
    
    var draftId: String {
        draftPoster.draft.id ?? ""
    }
    
    init(draftPoster: StatusDraftPoster) {
        self.draftPoster = draftPoster
        self.showPlaceholder = draftPoster.originalContent.isEmpty
    }
    
    var body: some View {
        VStack(alignment: .trailing) {
            if focusedField == nil && draftPoster.draft.publishable {
                StatusRowView.Preview(draft: draftPoster.draft, post: {
                    Task {
                        if draftId.isEmpty {
                            draftPoster.address = actingAddress
                        }
                        await draftPoster.perform()
                    }
                })
                .padding()
                .transition(.slide)
                Divider()
            }
            EmojiPicker(text: $draftPoster.draft.emoji, placeholder: "🫥")
                .focused($focusedField, equals: .emoji)
                .frame(width: 66, height: 66)
                .padding(2)
                .background(Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.trailing)
            TextEditor(text: $draftPoster.draft.content)
                .padding(.horizontal, 4)
                .background(Color(UIColor.systemBackground))
                .padding(.bottom)
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        Button {
                            withAnimation {
                                focusedField = nil
                            }
                        } label: {
                            Text("Preview")
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .onAppear {
                    withAnimation {
                        focusedField = .emoji
                    }
                }
                .focused($focusedField, equals: .content)
                .overlay(alignment: .topLeading) {
                    placeholder
                        .padding(8)
                        .foregroundColor(.gray)
                }
                .background(Material.regular)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                .frame(maxHeight: focusedField == .content ? .infinity : nil)
        }
        .padding(.bottom)
        .background(Color.lolBackground)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ThemedTextView(text: draftPoster.navigationTitle, font: .title)
            }
        }
        .onAppear {
            if draftPoster.draft.address == .autoUpdatingAddress {
                draftPoster.address = actingAddress
            }
        }
    }
    
    @ViewBuilder
    var placeholder: some View {
        switch (focusedField, draftPoster.draft.content.isEmpty) {
        case (.content, _):
            EmptyView()
        case (_, true):
            Text("what's new?")
        default:
            EmptyView()
        }
//        if focusedField != .content && draftPoster.draft.content.isEmpty {
//            Text("What I'm up to")
//                .padding(4)
//                .padding(.vertical, 4)
//        }
    }
    
    @ViewBuilder
    var addressSelector: some View {
        if draftId.isEmpty {
            AddressNameView(actingAddress)
                .padding(.horizontal)
            if expandAddresses {
                ForEach(sceneModel.accountModel.myAddresses) { address in
                    if address != actingAddress {
                        Button {
                            withAnimation {
                                actingAddress = address
                                expandAddresses = false
                            }
                        } label: {
                            AddressNameView(address)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        } else {
            // Show Address
            AddressNameView(draftPoster.address)
        }
    }
}
