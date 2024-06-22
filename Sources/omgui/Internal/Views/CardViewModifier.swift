//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 5/7/23.
//

import SwiftUI

struct CardViewModifier: ViewModifier {
    let color: Color
    let background: Color?
    let padding: CGFloat
    let radius: CGFloat
    
    init(color: Color = .lolRandom(), backgroundColor: Color? = nil, padding: CGFloat, radius: CGFloat) {
        self.color = color
        self.background = backgroundColor
        self.padding = padding
        self.radius = radius
    }
    
    func body(content: Content) -> some View {
            content
                .frame(maxWidth: .infinity)
                .padding(padding)
                .background(background ?? Color.clear)
                .background(Material.regular)
                .foregroundStyle(color)
                .cornerRadius(radius)
                .shadow(radius: 4, y: 2)
    }
}

extension HStack {
    func asCard(color: Color = .lolRandom(), backgroundColor: Color? = nil, padding: CGFloat = 8, radius: CGFloat = 0) -> some View {
        self.modifier(CardViewModifier(color: color, backgroundColor: backgroundColor, padding: padding, radius: radius))
    }
}
extension VStack {
    func asCard(color: Color = .lolRandom(), backgroundColor: Color? = nil, padding: CGFloat = 8, radius: CGFloat = 0) -> some View {
        self.modifier(CardViewModifier(color: color, backgroundColor: backgroundColor, padding: padding, radius: radius))
    }
}
extension View {
    func asCard(color: Color = .lolRandom(), backgroundColor: Color? = nil, padding: CGFloat = 8, radius: CGFloat = 0) -> some View {
        HStack {
            self
            Spacer(minLength: 0)
        }
        .asCard(color: color, backgroundColor: backgroundColor, padding: padding, radius: radius)
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
    }
}
