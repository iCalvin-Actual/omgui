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
    let path: String?
    
    init(_ name: AddressName, font: Font = .title, path: String? = nil) {
        self.name = name
        self.font = font
        self.path = path
    }
    
    var body: some View {
        ThemedTextView(text: name.addressDisplayString, font: font, suffix: path)
    }
}

extension AddressName {
    var addressDisplayString: String { "@\(self)"}
}
