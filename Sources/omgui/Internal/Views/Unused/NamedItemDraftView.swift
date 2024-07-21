//
//  SwiftUIView.swift
//
//
//  Created by Calvin Chestnut on 4/5/23.
//

import SwiftUI

struct NamedItemDraftView<D: NamedDraftable>: View {
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Title")
                    .font(.callout)
//                TextField("Title", text: $fetcher.namedDraft.name)
            }
            
//            Toggle("Public", isOn: $fetcher.namedDraft.listed)
                
//            TextEditor(text: $fetcher.namedDraft.content)
        }
        .toolbar {
            ToolbarItem {
                Button {
                    Task {
//                        await fetcher.perform()
                    }
                } label: {
                    Text("Save")
                }

            }
        }
    }
}
