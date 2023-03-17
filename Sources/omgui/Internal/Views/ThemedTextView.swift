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
    let design: Font.Design
    
    init(text: String, font: Font = .title, design: Font.Design = .serif) {
        self.text = text
        self.font = font
        self.design = design
    }
    
    var body: some View {
        Text(text)
            .font(font)
            .fontDesign(design)
            .foregroundColor(.accentColor)
            .bold()
    }
}
