//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/28/23.
//

import SwiftUI

struct EditPageView<D: MDDraft>: View {
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    @StateObject
    var poster: MDDraftPoster<D>
    
    var body: some View {
        TextEditor(text: $poster.draft.content)
            .toolbar {
                ToolbarItem {
                    saveButton
                }
            }
    }
    
    @ViewBuilder
    var saveButton: some View {
        Button {
            Task {
                await poster.perform()
            }
        } label: {
            Text("Save")
        }
    }
}

