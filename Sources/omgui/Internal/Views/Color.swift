//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

extension Color {
    static let lolGreen: Color =    .init(hex: "8be899")
    static let lolYellow: Color =   .init(hex: "ffdf66")
    static let lolTeal: Color =     .init(hex: "65d8e7")
    static let lolPink: Color =     .init(hex: "f782ac")
    static let lolPurple: Color =   .init(hex: "d0bfff")
    static let lolBlue: Color =     .init(hex: "a5d8ff")
    static let lolOrange: Color =   .init(hex: "ffd8a8")
    static let lolAccent: Color =   .init(hex: "e34199")
    
    static func lolRandom(_ input: any Hashable) -> Color {
        let hash = input.hashValue
        let colors: [Color] = [
            .lolGreen,
            .lolYellow,
            .lolTeal,
            .lolPink,
            .lolPurple,
            .lolBlue,
            .lolOrange
        ]
        
        let modValue = abs(hash % colors.endIndex)
        
        return colors[modValue]
    }
}
