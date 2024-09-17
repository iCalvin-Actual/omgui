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
    
    let poster: MDDraftPoster<D>
    
    var body: some View {
        EmptyView()
//        TextEditor(text: $poster.draft.content)
            .toolbar {
                ToolbarItem {
                    saveButton
                }
            }
    }
    
    @ViewBuilder
    var saveButton: some View {
        Button {
            Task { [poster] in
                await poster.perform()
            }
        } label: {
            Text("save")
        }
    }
}

