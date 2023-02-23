//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 2/12/23.
//

import SwiftUI
import Foundation

@available(iOS 16.1, *)
struct ProfileGridView<L: View>: View {
    let model: ProfileGridItemModel
    
    @ViewBuilder
    let destination: (ProfileGridItem) -> L
    
    init(model: ProfileGridItemModel, @ViewBuilder destination: @escaping (ProfileGridItem) -> L) {
        self.model = model
        self.destination = destination
    }
    
    var body: some View {
        if model.isLoaded {
            NavigationLink(value: model.item, label: label)
        } else {
            self.label()
        }
    }
    
    @ViewBuilder
    func label() -> some View {
        HStack {
            Spacer()
            model.label
            Spacer()
        }
        .background(Color.lolBlue, in: Capsule())
    }
}
