//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct PURLRowView: View {
    let model: PURLModel
    @Environment(\.viewContext)
    var context: ViewContext
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                if context != .profile {
                    AddressNameView(model.owner, font: .title3)
                        .padding(2)
                }
                Spacer()
                AddressIconView(address: model.owner)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("/\(model.value)")
                        .font(.title2)
                        .bold()
                        .fontDesign(.serif)
                        .lineLimit(2)
                    Spacer()
                }
                
                if let destination = model.destination {
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
            .background(Color.lolRandom(model.value))
            .cornerRadius(12, antialiased: true)
            .padding(.vertical, 4)
        }
        .frame(maxWidth: .infinity)
    }
}
