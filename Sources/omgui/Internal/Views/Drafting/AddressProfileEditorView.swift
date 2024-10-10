//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/28/23.
//

import SwiftUI
import MarkupEditor

public struct AddressProfileEditorView: View {
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
    
    public var body: some View {
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

