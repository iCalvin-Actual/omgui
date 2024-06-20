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
