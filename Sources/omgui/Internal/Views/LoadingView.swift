//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 6/9/24.
//

import SwiftUI

struct LoadingView: View {
    enum Style {
        case standard
        case horizontal
    }
    
    let style: Style
    
    init(_ style: Style = .standard) {
        self.style = style
    }
    
    var body: some View {
        content
            .listRowSeparator(.hidden)
    }
    
    @ViewBuilder
    var content: some View {
        switch style {
        case .standard:
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(2.0, anchor: .center)
                    .tint(.accentColor)
                ThemedTextView(text: "loading...")
            }
            .padding(4)
        case .horizontal:
            HStack(spacing: 16) {
                ThemedTextView(text: "loading...")
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(2.0, anchor: .center)
                    .tint(.accentColor)
                Spacer()
            }
            .frame(maxHeight: 61.33)
        }
    }
}

#Preview {
    LoadingView()
}
