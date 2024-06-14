//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct AddressContentButton: View {
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    let contentType: AddressContent
    let name: AddressName
    let knownEmpty: Bool
    let accessoryText: String?
    
    var body: some View {
        HStack {
            HStack {
                NavigationLink(value: contentType.destination(name)) {
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
                    if let text = accessoryText {
                        Text(text)
                            .font(.subheadline)
                            .bold()
                    }
                }
                .disabled(knownEmpty)
                
                if sceneModel.addressBook.myAddresses.contains(name) && false {
                    NavigationLink(value: contentType.editingDestination(name)) {
                        VStack {
                            Image(systemName: "pencil.line")
                                .font(.subheadline)
                                .bold()
                            
                            Text(contentType.editText)
                                .font(.headline)
                                .fontDesign(.serif)
                        }
                        .frame(minWidth: 55)
                        .padding(8)
                        .foregroundColor(.black)
                        .background(contentType.color)
                        .cornerRadius(12, antialiased: true)
                    }
                }
            }
            .padding(8)
            .foregroundColor(.black)
            .background(contentType.color)
            .cornerRadius(12, antialiased: true)
        }
        .padding(.horizontal)
    }
}
