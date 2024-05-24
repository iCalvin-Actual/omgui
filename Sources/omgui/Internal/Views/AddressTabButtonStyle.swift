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
            .padding(.horizontal, 16)
            .frame(maxHeight: .infinity)
            .background(isActive ? Color(uiColor: UIColor.tintColor) : .clear)
            .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 20, topTrailing: 20), style: .circular))
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
