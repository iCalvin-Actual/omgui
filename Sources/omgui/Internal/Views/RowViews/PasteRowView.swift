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
            HStack(alignment: .bottom) {
                if context != .profile {
                    AddressIconView(address: model.owner)
                    AddressNameView(model.owner)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                if let caption = model.listCaption {
                    Text(caption)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fontDesign(.rounded)
                }
            }
            .padding(4)
            .padding(.horizontal, 4)
            .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("/\(model.name)")
                    .font(.title3)
                    .fontDesign(.serif)
                    .bold()
                    .lineLimit(3)
                
                if !model.content.isEmpty {
                    Text(model.content)
                        .font(.body)
                        .fontDesign(.rounded)
                        .lineLimit(5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.secondary)
                }
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity)
            .asCard(color: cardColor, material: .regular, padding: cardPadding, radius: cardradius, selected: showSelection)
        }
        .asCard(color: cardColor, padding: 0, radius: cardradius, selected: showSelection)
        .frame(maxWidth: .infinity)
    }
}
