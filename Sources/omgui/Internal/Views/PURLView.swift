//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 4/26/23.
//

import SwiftUI

struct PURLView: View {
    
    @ObservedObject
    var fetcher: AddressPURLDataFetcher
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(fetcher.purl?.value ?? fetcher.title)
                    .font(.title)
                Text(fetcher.purl?.destination ?? "")
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}
