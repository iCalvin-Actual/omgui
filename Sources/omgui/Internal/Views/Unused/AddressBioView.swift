//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftData
import SwiftUI

struct AddressBioView: View {
    @Environment(\.verticalSizeClass)
    var verticalSizeClass
    
    var bio: AddressBioModel
    
    @State
    var expanded: Bool = false
    
    var lineLimit: Int? {
        guard !expanded else {
            return nil
        }
        switch verticalSizeClass {
        case .compact:
            return 1
        default:
            return 3
        }
    }
    
    var body: some View {
        Text(bio.bio)
            .onTapGesture {
                withAnimation {
                    self.expanded.toggle()
                }
            }
            .padding()
            .lineLimit(lineLimit)
            .frame(maxWidth: .infinity)
            .background(Color.lolBlue)
    }
}
