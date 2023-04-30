//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 4/27/23.
//

import SwiftUI

struct StatusDraftView: View {
    @ObservedObject
    var draftPoster: StatusDraftPoster
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack {
                    Button {
                        // Show emoji picker
                    } label: {
                        Text("✨")
                            .font(.largeTitle)
                    }

                    Text("Choose an emoji")
                        .font(.caption2)
                }
                
                VStack(alignment: .leading) {
                    TextEditor(text: $draftPoster.draft.content)
                        .frame(maxHeight: 125)
                    
                    Button {
                        Task {
                            await draftPoster.perform()
                        }
                    } label: {
                        Text("Save")
                            .padding()
                            .background(Color.lolBlue)
                            .cornerRadius(4)
                    }

                }
            }
        }
    }
}
