//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct PURLRowView: View {
    let model: PURLModel
    let context: ViewContext
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if context != .profile {
                AddressNameView(model.owner, font: .title3)
                    .padding(2)
            }
            
            VStack(alignment: .leading) {
                Text(model.value)
                    .font(.largeTitle)
                    .padding(.vertical)
                
                HStack(alignment: .bottom) {
                    if let destination = model.destination {
                        Text(destination)
                            .font(.caption)
                            .foregroundColor(.black.opacity(0.8))
                            .padding(.bottom)
                    }
                    Spacer()
                }
            }
            .multilineTextAlignment(.leading)
            .padding(12)
            .accentColor(.black)
            .background(Color.lolRandom(model.value))
            .cornerRadius(12, antialiased: true)
        }
    }
}
