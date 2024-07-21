//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftData
import SwiftUI

struct AddressBioLabel: View {
    @Binding
    var expanded: Bool
    
    var bio: AddressBioModel
    
    var body: some View {
        contentView(bio.bio)
            .onTapGesture {
                withAnimation {
                    expanded.toggle()
                }
            }
    }
    
    @ViewBuilder
    func contentView(_ bio: String) -> some View {
        if expanded {
            ScrollView {
                MarkdownContentView(content: bio)
            }
        } else {
            Text(bio)
                .lineLimit(3)
                .font(.caption)
                .fontDesign(.monospaced)
        }
    }
}
