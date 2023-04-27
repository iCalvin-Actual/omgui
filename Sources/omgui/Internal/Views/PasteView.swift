//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 4/26/23.
//

import SwiftUI

struct PasteView: View {
    
    @ObservedObject
    var fetcher: AddressPasteDataFetcher
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(fetcher.paste?.name ?? fetcher.title)
                    .font(.title)
                Text(fetcher.paste?.content ?? "")
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}
