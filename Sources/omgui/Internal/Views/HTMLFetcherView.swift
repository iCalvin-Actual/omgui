//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 6/9/24.
//

import SwiftUI

struct HTMLFetcherView: View {
    @ObservedObject
    var fetcher: DataFetcher
    
    let activeAddress: AddressName?
    let htmlContent: String?
    let baseURL: URL?
    
    @State
    var presentedURL: URL? = nil
    
    var body: some View {
        HTMLContentView(
            activeAddress: activeAddress,
            htmlContent: htmlContent,
            baseURL: baseURL,
            activeURL: $presentedURL
        )
        .overlay(content: {
            if fetcher.loading {
                LoadingView()
                    .padding(24)
                    .background(Material.regular)
            }
        })
        .sheet(item: $presentedURL, content: { url in
            SafariView(url: url)
                .ignoresSafeArea(.all, edges: .bottom)
        })
    }
}

