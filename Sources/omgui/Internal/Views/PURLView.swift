//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 4/26/23.
//

import SwiftUI

struct PURLView: View {
    @Environment(\.horizontalSizeClass)
    var sizeClass
    
    @ObservedObject
    var fetcher: AddressPURLDataFetcher
    
    @State
    var presentedURL: URL?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Group {
                    switch sizeClass {
                    case .compact:
                        Text("/\(fetcher.purl?.value ?? fetcher.title)")
                            .font(.title3)
                            .foregroundStyle(Color.primary)
                    default:
                        Text("\(fetcher.addressName).purl.lol/")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Color.accentColor)
                        +
                        Text(fetcher.purl?.value ?? fetcher.title)
                            .font(.title3)
                            .foregroundStyle(Color.primary)
                    }
                }
                .fontDesign(.monospaced)
                .lineLimit(2)
                
                Spacer()
                if let destination = fetcher.purl?.destination {
                    Text(destination)
                        .textSelection(.enabled)
                        .font(.caption)
                        .fontDesign(.serif)
                        .lineLimit(2)
                        .multilineTextAlignment(.trailing)
                }
            }
            .padding(.top)
            .padding(.horizontal)
            
            if let content = fetcher.purlContent {
                HTMLContentView(
                    activeAddress: fetcher.addressName,
                    htmlContent: content,
                    baseURL: {
                        guard let destination = fetcher.purl?.destinationURL else {
                            return nil
                        }
                        guard let scheme = destination.scheme, let host = destination.host() else {
                            return nil
                        }
                        return URL(string: "\(scheme)://\(host)")
                    }(),
                    activeURL: $presentedURL
                )
                .sheet(item: $presentedURL, content: { url in
                    SafariView(url: url)
                        .ignoresSafeArea(.all, edges: .bottom)
                })
            } else {
                Spacer()
            }
        }
        .toolbar {
            if let name = fetcher.purl?.value {
                ToolbarItem(placement: .topBarLeading) {
                    ThemedTextView(text: "/\(name)")
                }
            }
        }
    }
}
