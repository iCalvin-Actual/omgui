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
        Group {
            content
                .frame(maxWidth: .infinity)
                .padding(padding)
                .background(color)
                .foregroundStyle(Color.primary)
                .cornerRadius(4)
                .shadow(color: colorScheme == .dark ? .white.opacity(0.2) : .black, radius: 0, x: 8, y: 8)
        }
        .padding(2)
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
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.lolBackground)
    }
}
