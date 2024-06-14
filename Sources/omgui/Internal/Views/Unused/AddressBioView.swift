//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct AddressBioView: View {
    @Environment(\.verticalSizeClass)
    var verticalSizeClass
    
    @ObservedObject
    var fetcher: AddressBioDataFetcher
    
    @State
    var expanded: Bool = false
    
    var lineLimit: Int? {
        guard !expanded else {
            return nil
        }
        switch verticalSizeClass {
        case .compact:
            return 1
        default:
            return 3
        }
    }
    
    var body: some View {
        if let bio = fetcher.bio?.bio {
            Text(bio)
                .onTapGesture {
                    withAnimation {
                        self.expanded.toggle()
                    }
                }
                .padding()
                .lineLimit(lineLimit)
                .frame(maxWidth: .infinity)
                .background(Color.lolBlue)
        }
    }
}
