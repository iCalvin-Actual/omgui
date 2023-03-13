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
    
    var body: some View {
        NavigationLink(value: contentType.destination(name)) {
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
