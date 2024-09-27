//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 6/9/24.
//

import SwiftUI

struct HTMLFetcherView: View {
    @Environment(\.horizontalSizeClass)
    var sizeClass
    
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
        .ignoresSafeArea(.container, edges: (sizeClass == .regular && UIDevice.current.userInterfaceIdiom == .pad) ? [.bottom] : [])
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
        .safeAreaInset(edge: .bottom) {
            if fetcher.loading {
                LoadingView()
                    .padding(24)
                    .background(Material.regular)
            }
        }
        .sheet(item: $presentedURL, content: { url in
            SafariView(url: url)
                .ignoresSafeArea(.container, edges: .all)
        })
    }
}

