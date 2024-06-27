//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 5/23/24.
//

import SwiftUI

struct AddressTabStyle: ButtonStyle {
    let isActive: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontDesign(.rounded)
            .bold()
            .padding(8)
            .padding(.bottom, 6)
            .frame(minWidth: 44, maxHeight: .infinity, alignment: .bottom)
            .background(isActive ? Color.accentColor : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(6)
            .foregroundColor(isActive ? .white : .primary)
            .bold(isActive)
    }
}

#Preview {
    HStack(spacing: 0) {
        Button(action: { }) {
            Text("Some")
        }
        .buttonStyle(AddressTabStyle(isActive: false))
        Button(action: { }) {
            Text("Other")
        }
        .buttonStyle(AddressTabStyle(isActive: true))
    }
    .frame(height: 60)
    .padding()
}
