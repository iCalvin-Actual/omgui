//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI
import Foundation

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Color {
    static let lolBackground: Color = .init(
        light: .init(hex: "f8f9fa"),
        dark: .init(hex: "343a40")
    )
    static let lolGreen: Color =    .init(hex: "8be899")
    static let lolYellow: Color =   .init(hex: "ffdf66")
    static let lolTeal: Color =     .init(hex: "65d8e7")
    static let lolPink: Color =     .init(hex: "f782ac")
    static let lolPurple: Color =   .init(hex: "d0bfff")
    static let lolBlue: Color =     .init(hex: "a5d8ff")
    static let lolOrange: Color =   .init(hex: "ffd8a8")
    static let lolAccent: Color =   .init(hex: "e34199")
    
    static func lolRandom(_ input: any Hashable = Int.random(in: 0...10)) -> Color {
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
