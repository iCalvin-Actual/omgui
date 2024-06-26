//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct PasteRowView: View {
    let model: PasteModel
    @Environment(\.viewContext)
    var context: ViewContext
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .bottom) {
                if context != .profile {
                    AddressNameView(model.owner, font: .title3)
                }
                Spacer()
                AddressIconView(address: model.owner)
            }
            .padding(2)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("/\(model.name)")
                        .font(.title2)
                        .bold()
                        .fontDesign(.serif)
                        .lineLimit(2)
                    Spacer()
                }
                
                if let destination = model.content {
                    Text(destination)
                        .font(.subheadline)
                        .fontDesign(.monospaced)
                        .lineLimit(5)
                }
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity)
            .padding(12)
            .foregroundColor(.black)
            .background(Color.lolRandom(model.name))
            .cornerRadius(12, antialiased: true)
            .padding(.vertical, 4)
        }
        .frame(maxWidth: .infinity)
    }
}
