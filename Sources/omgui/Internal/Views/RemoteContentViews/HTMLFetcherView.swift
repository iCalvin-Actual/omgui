//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 6/9/24.
//

import SwiftUI

struct HTMLFetcherView: View {
    @ObservedObject
    var fetcher: Request
    
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
        .ignoresSafeArea(.container, edges: .bottom)
        .safeAreaInset(edge: .bottom) {
            if let url = baseURL {
                Link(destination: url) {
                    Label {
                        Text("Open URL")
                    } icon: {
                        Image(systemName: "link")
                    }
                    .padding()
                    .background(Material.thin)
                    .cornerRadius(16)
                }
                .frame(maxWidth: .infinity)
                .background(Color.clear)
            }
        }
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

