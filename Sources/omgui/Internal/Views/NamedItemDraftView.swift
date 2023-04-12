//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 4/5/23.
//

import SwiftUI

struct NamedItemDraftView<D: NamedDraft>: View {
    @ObservedObject
    var fetcher: DraftPoster<D>
    
    @State
    var title: String = ""
    var content: String = ""
    
    var body: some View {
        Form {
            TextField("Title", text: $fetcher.draft.name)
        }
    }
}
