//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct AddressContentButton: View {
    let contentType: AddressContent
    let name: AddressName
    let preferEditing: Bool
    
    var preferredDestination: NavigationDestination {
        if preferEditing {
            return contentType.editingDestination(name)
        } else {
            return contentType.destination(name)
        }
    }
    
    var body: some View {
        NavigationLink(value: preferredDestination) {
            HStack {
                Spacer()
                VStack {
                    Image(systemName: contentType.icon)
                        .font(.subheadline)
                        .bold()
                    
                    Text(contentType.displayString)
                        .font(.headline)
                        .fontDesign(.serif)
                }
                Spacer()
            }
            .padding(8)
            .foregroundColor(.black)
            .background(contentType.color)
            .cornerRadius(12, antialiased: true)
        }
    }
}
