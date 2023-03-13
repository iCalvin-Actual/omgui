//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct PasteView: View {
    let model: PasteModel
    let context: ViewContext
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if context != .profile {
                AddressNameView(model.owner, font: .title3)
                    .padding(2)
            }
            
            VStack(alignment: .leading) {
                Text(model.name)
                    .foregroundColor(.accentColor)
                    .font(.largeTitle)
                    .padding(.vertical)
                
                HStack(alignment: .bottom) {
                    if let destination = model.content {
                        Text(destination)
                            .font(.body)
                            .foregroundColor(.black)
                            .padding(.bottom)
                    }
                    Spacer()
                }
            }
            .multilineTextAlignment(.leading)
            .padding(12)
            .accentColor(.black)
            .background(Color.lolRandom(model.name))
            .cornerRadius(12, antialiased: true)
        }
    }
}
