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
    
    var body: some View {
        Text(text)
            .font(font)
            .fontDesign(.serif)
            .foregroundColor(.accentColor)
            .bold()
    }
}
