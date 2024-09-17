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
                    AddressIconView(address: model.owner)
                    AddressNameView(model.owner)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(2)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("/\(model.name)")
                        .font(.title3)
                        .fontDesign(.serif)
                        .bold()
                        .lineLimit(3)
                    Spacer()
                }
                
                if !model.content.isEmpty {
                    Text(model.content)
                        .font(.body)
                        .fontDesign(.rounded)
                        .lineLimit(5)
                }
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity)
            .foregroundStyle(Color.black)
            .asCard(color: cardColor, padding: cardPadding, radius: cardradius, selected: showSelection)
        }
        .frame(maxWidth: .infinity)
    }
}
