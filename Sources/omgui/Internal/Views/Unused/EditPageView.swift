//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/28/23.
//

import SwiftUI

struct EditPageView<D: MDDraftable>: View {
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    var body: some View {
//        TextEditor(text: $poster.draft.content)
        EmptyView()
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
//                await poster.perform()
            }
        } label: {
            Text("save")
        }
    }
}

