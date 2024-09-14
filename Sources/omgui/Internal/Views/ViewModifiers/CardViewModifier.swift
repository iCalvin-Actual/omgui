//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 5/7/23.
//

import SwiftUI

struct CardViewModifier: ViewModifier {
    @Environment(\.colorScheme) 
    var colorScheme
    @Environment(\.colorSchemeContrast)
    var contrast
    
    let color: Color
    let background: Color?
    let padding: CGFloat
    let radius: CGFloat
    let selected: Bool
    
    var shadowOffset: CGFloat {
        selected ? 8 : 2
    }
    
    init(color: Color = .lolRandom(), backgroundColor: Color? = nil, padding: CGFloat, radius: CGFloat, selected: Bool) {
        self.color = color
        self.background = backgroundColor
        self.padding = padding
        self.radius = radius
        self.selected = selected
    }
    
    func body(content: Content) -> some View {
        Group {
            content
                .frame(maxWidth: .infinity)
                .padding(padding)
                .background(contrast == .increased ? Material.ultraThick : Material.thin)
                .cornerRadius(radius)
                .shadow(color: selected ? .black : .clear, radius:  radius, x: shadowOffset, y: shadowOffset)
        }
        .padding(2)
    }
}

extension HStack {
    func asCard(color: Color = .lolRandom(), backgroundColor: Color? = nil, padding: CGFloat = 4, radius: CGFloat = 2, selected: Bool = false) -> some View {
        self.modifier(CardViewModifier(color: color, backgroundColor: backgroundColor, padding: padding, radius: radius, selected: selected))
    }
}
extension VStack {
    func asCard(color: Color = .lolRandom(), backgroundColor: Color? = nil, padding: CGFloat = 4, radius: CGFloat = 2, selected: Bool = false) -> some View {
        self.modifier(CardViewModifier(color: color, backgroundColor: backgroundColor, padding: padding, radius: radius, selected: selected))
    }
}
extension View {
    func asCard(color: Color = .lolRandom(), backgroundColor: Color? = nil, padding: CGFloat = 4, radius: CGFloat = 2, selected: Bool = false) -> some View {
        HStack {
            self
            Spacer(minLength: 0)
        }
        .asCard(color: color, backgroundColor: backgroundColor, padding: padding, radius: radius, selected: selected)
    }
}

struct CardViewModifier_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            Text("Some")
                .font(.title)
            
            Spacer()
            
            Image(systemName: "tree.fill")
        }
        .asCard(color: .lolPink)
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.lolBackground)
    }
}
