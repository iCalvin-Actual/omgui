//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 6/9/24.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(2.0, anchor: .center)
                .tint(.accentColor)
            ThemedTextView(text: "loading...")
        }
        .padding()
    }
}

#Preview {
    LoadingView()
}
