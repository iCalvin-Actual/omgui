//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 4/5/23.
//

import SwiftUI

struct NamedItemDraftView<D: NamedDraft>: View {
    @ObservedObject
    var fetcher: NamedDraftPoster<D>
    
    public init(fetcher: NamedDraftPoster<D>) {
        self.fetcher = fetcher
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            HStack {
                Text("Title")
                    .font(.callout)
                TextField("Title", text: $fetcher.draft.name)
            }
            
            Toggle("Public", isOn: $fetcher.draft.listed)
                
            TextEditor(text: $fetcher.draft.content)
        }
        .toolbar {
            ToolbarItem {
                Button {
                    Task {
                        await fetcher.perform()
                    }
                } label: {
                    Text("Save")
                }

            }
        }
    }
}
