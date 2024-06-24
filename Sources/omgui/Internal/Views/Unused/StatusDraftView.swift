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
    @SceneStorage("app.lol.address")
    var actingAddress: AddressName = ""
    
    @State
    var expandAddresses: Bool = false
    @State
    var showPlaceholder: Bool = true
    @State
    var showConfirmation: Bool = true
    @State
    var clearResult: Bool = true
    
    enum FocusField: Hashable {
        case emoji
        case content
    }
    @FocusState
    private var focusedField: FocusField?
    
    @ObservedObject
    var draftPoster: StatusDraftPoster
    
    @State
    var innerConfirmDelete: Bool = false
    @State
    var confirmDelete: Bool = false
    @State
    var velocity: CGSize = .zero
    @State
    var previewResult: StatusModel? = nil
    @State
    var presentedPreview: StatusModel? = nil
    
    var bindingEmoji: Binding<String> {
        .init {
            draftPoster.draft.emoji
        } set: { newValue in
            draftPoster.draft.emoji = newValue
        }

    }
    
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
                        draftPoster.draft.clear()
                        focusedField = .emoji
                        previewResult = draftPoster.result
                    }
                })
                .padding()
                .transition(.slide)
                Divider()
            }
            emojiField(bindingEmoji)
            
            editorView
                .sheet(item: $presentedPreview, onDismiss: {
                    withAnimation {
                        if clearResult {
                            draftPoster.draft.clear()
                            focusedField = .emoji
                        } else {
                            focusedField = .content
                            previewResult = nil
                            clearResult = true
                        }
                    }
                }) { result in
                    NavigationStack {
                        sceneModel.destinationConstructor.appliedDestination(.status(result.address, id: result.id))
                            .toolbar {
                                ToolbarItem(placement: .topBarTrailing) {
                                    Button {
                                        withAnimation {
                                            clearResult = false
                                            if let presented = presentedPreview {
                                                draftPoster.result = presented
                                                draftPoster.draft = .init(model: presented, id: presented.id)
                                            }
                                            presentedPreview = nil
                                        }
                                    } label: {
                                        Text("edit")
                                    }
                                }
                                ToolbarItem(placement: .topBarLeading) {
                                    Button {
                                        innerConfirmDelete = true
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                }
                            }
                            .alert("Are you sure?", isPresented: $innerConfirmDelete, actions: {
                                Button("Cancel", role: .cancel) { }
                                Button(
                                    "Yes",
                                    role: .destructive,
                                    action: deletePresented
                                )
                            }, message: {
                                Text("Are you sure you want to delete this status?")
                            })
                    }
                }
        }
        .background(Color.lolBackground)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ThemedTextView(text: draftPoster.navigationTitle, font: .title)
            }
            ToolbarItem(placement: .topBarTrailing) {
                if !(draftPoster.draft.id ?? "").isEmpty {
                    Button(role: .destructive) {
                        confirmDelete = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .alert("Are you sure?", isPresented: $confirmDelete, actions: {
            Button("Cancel", role: .cancel) { }
            Button(
                "Yes",
                role: .destructive,
                action: deleteLive
            )
        }, message: {
            Text("Are you sure you want to delete this status?")
        })
        .onAppear {
            if draftPoster.draft.address == .autoUpdatingAddress {
                draftPoster.address = actingAddress
            }
        }
    }
    
    func deleteLive() {
        guard let credential = sceneModel.accountModel.credential(for: draftPoster.address, in: sceneModel.addressBook) else {
            return
        }
        let toDelete = draftPoster.draft
        Task {
            let _ = try await sceneModel.accountModel.interface.deleteAddressStatus(toDelete, from: draftPoster.address, credential: credential)
            draftPoster.draft.clear()
            
            withAnimation {
                previewResult = nil
                presentedPreview = nil
            }
        }
    }
    
    func deletePresented() {
        guard let credential = sceneModel.accountModel.credential(for: draftPoster.address, in: sceneModel.addressBook), let presented = presentedPreview else {
            return
        }
        let draft = StatusModel.Draft(model: presented, id: presented.id)
        Task {
            if let backup = try await sceneModel.accountModel.interface.deleteAddressStatus(draft, from: draftPoster.address, credential: credential) {
                let newDraft: StatusModel.Draft = .init(model: backup)
                draftPoster.draft = newDraft
            }
            
            withAnimation {
                previewResult = nil
                presentedPreview = nil
            }
        }
    }
    
    func hideConfirmation() async {
        try? await Task.sleep(nanoseconds: 20_100_000_000)
        withAnimation {
            showConfirmation = false
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
    
    @ViewBuilder
    private func emojiField(_ binding: Binding<String>) -> some View {
        EmojiPicker(text: binding, placeholder: "🫥")
            .focused($focusedField, equals: .emoji)
            .frame(width: 66, height: 66)
            .padding(2)
            .background(Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.trailing)
    }
    
    @ViewBuilder
    private var editorView: some View {
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
                        Text("preview")
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
            .overlay(alignment: .bottom) {
                if let result = previewResult {
                    StatusRowView(model: result)
                        .task {
                            await delayText()
                        }
                        .padding(.horizontal)
                        .background(Material.regular)
                        .mask {
                            RoundedRectangle(cornerRadius: 12)
                        }
                        .padding([.bottom, .horizontal], 8)
                        .onTapGesture {
                            draftPoster.draft = .init(model: result, id: result.id)
                        }
                        .gesture(
                            simpleDrag
                        )
                        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .offset(x: velocity.width, y: velocity.height).combined(with: .opacity)))
                }
            }
    }
    
    private func delayText() async {
        try? await Task.sleep(nanoseconds: 27_100_000_000)
        withAnimation {
            previewResult = nil
        }
    }
    
    private var simpleDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                let horizontal = abs(value.velocity.width)
                let vertical = abs(value.velocity.height)
                
                if horizontal > 500 || vertical > 700 {
                    velocity = value.velocity
                    withAnimation {
                        previewResult = nil
                    }
                }
            }
    }
}
