//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct ThemedTextView: View {
    let text: String
    let font: Font
    
    init(text: String, font: Font = .title) {
        self.text = text
        self.font = font
    }
    
    var body: some View {
        Text(text)
            .font(font)
            .fontDesign(.serif)
            .foregroundColor(.accentColor)
            .bold()
    }
}
