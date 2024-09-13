//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct PasteRowView: View {
    @Environment(\.viewContext)
    var context: ViewContext
    
    let model: PasteModel
    
    let cardColor: Color
    let cardPadding: CGFloat
    let cardradius: CGFloat
    let showSelection: Bool
    
    init(model: PasteModel, cardColor: Color, cardPadding: CGFloat, cardradius: CGFloat, showSelection: Bool) {
        self.model = model
        self.cardColor = cardColor
        self.cardPadding = cardPadding
        self.cardradius = cardradius
        self.showSelection = showSelection
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if context != .profile {
                HStack(alignment: .bottom) {
                    AddressNameView(model.owner, font: .title3)
                    Spacer()
                    AddressIconView(address: model.owner)
                }
                .padding(2)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("/\(model.name)")
                        .font(.title2)
                        .bold()
                        .fontDesign(.serif)
                        .lineLimit(2)
                    Spacer()
                }
                
                if !model.content.isEmpty {
                    Text(model.content)
                        .font(.subheadline)
                        .fontDesign(.monospaced)
                        .lineLimit(5)
                }
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity)
            .padding(12)
            .foregroundColor(.black)
            .cornerRadius(12, antialiased: true)
            .foregroundStyle(Color.black)
            .asCard(color: cardColor, padding: cardPadding, radius: cardradius, selected: showSelection)
        }
        .frame(maxWidth: .infinity)
    }
}
