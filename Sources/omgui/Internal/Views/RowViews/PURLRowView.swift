//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct PURLRowView: View {
    @Environment(\.viewContext)
    var context: ViewContext
    
    let model: PURLModel
    
    let cardColor: Color
    let cardPadding: CGFloat
    let cardradius: CGFloat
    let showSelection: Bool
    
    init(model: PURLModel, cardColor: Color, cardPadding: CGFloat, cardradius: CGFloat, showSelection: Bool) {
        self.model = model
        self.cardColor = cardColor
        self.cardPadding = cardPadding
        self.cardradius = cardradius
        self.showSelection = showSelection
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                if context != .profile {
                    HStack(alignment: .bottom, spacing: 0) {
                        AddressIconView(address: model.owner)
                            .padding(.horizontal, 4)
                        AddressNameView(model.owner)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    Spacer()
                }
                if let caption = model.listCaption {
                    Text(caption)
                        .multilineTextAlignment(.trailing)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .truncationMode(.head)
                }
            }
            .padding(.top, 6)
            .padding(4)
            .padding(.horizontal, 4)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("/\(model.name)")
                    .font(.headline)
                    .bold()
                    .fontDesign(.serif)
                    .lineLimit(3)
                if !model.content.isEmpty {
                    Text(model.content)
                        .font(.body)
                        .fontDesign(.monospaced)
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
