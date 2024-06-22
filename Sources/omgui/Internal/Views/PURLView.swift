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
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    @Environment(\.viewContext)
    var context: ViewContext
    
    @ObservedObject
    var fetcher: AddressPURLDataFetcher
    
    var body: some View {
        VStack(alignment: .leading) {
            if context != .profile {
                HStack(alignment: .top) {
                    Spacer()
                    ThemedTextView(text: fetcher.addressName.addressDisplayString)
                    Menu {
                        AddressModel(name: fetcher.addressName).contextMenu(in: sceneModel)
                    } label: {
                        AsyncImage(url: fetcher.addressName.addressIconURL) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.lolRandom(fetcher.addressName)
                        }
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
    //                    .padding(.vertical, 8)
                    }
                    .padding(.trailing)
                }
            }
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
                HTMLFetcherView(
                    fetcher: fetcher,
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
                    }()
                )
            } else {
                Spacer()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ThemedTextView(text: "/\(fetcher.title)")
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if let purlURL = URL(string: "https://\(fetcher.addressName).url.lol/\(fetcher.title)") {
                        ShareLink(item: purlURL)
                        Button(action: {
                            // Copy Content
                        }, label: {
                            Label(
                                title: { Text("Copy PURL") },
                                icon: { Image(systemName: "doc.on.doc") }
                            )
                        })
                    }
                    Divider()
                    if let shareURL = fetcher.purl?.destinationURL {
                        ShareLink("Share destination URL", item: shareURL)
                        Button(action: {
                            // Copy URL
                        }, label: {
                            Label(
                                title: { Text("Copy destination") },
                                icon: { Image(systemName: "link") }
                            )
                        })
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
}
