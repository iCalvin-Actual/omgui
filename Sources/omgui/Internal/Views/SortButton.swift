//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct SortOrderMenu: View {
    @Binding
    var sort: Sort
    
    var options: [Sort]
    
    private func button(_ sort: Sort) -> some View {
        Button {
            withAnimation {
                self.sort = sort
            }
        } label: {
            if self.sort == sort {
                Label(sort.displayString, systemImage: "checkmark")
            } else {
                Text(sort.displayString)
            }
        }
    }
    
    var body: some View {
        Menu {
            ForEach(options) { sort in
                button(sort)
            }
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down.square")
        }
    }
}
