//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct AddressNameView: View {
    let name: AddressName
    let font: Font
    
    init(_ name: AddressName, font: Font = .title) {
        self.name = name
        self.font = font
    }
    
    var body: some View {
        ThemedTextView(text: name.addressDisplayString, font: font)
    }
}

extension AddressName {
    var addressDisplayString: String { "@\(self)"}
}
