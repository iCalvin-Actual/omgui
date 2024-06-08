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
    
    var context: ViewContext
    
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                Text("\(fetcher.addressName).paste.lol/")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color.accentColor)
                +
                Text(fetcher.paste?.name ?? fetcher.title)
                    .font(.title3)
                    .foregroundStyle(Color.primary)
            }
            .fontDesign(.monospaced)
            .padding(.top)
            .padding(.horizontal)
            
            ScrollView {
                Text(fetcher.paste?.content ?? "")
                    .textSelection(.enabled)
                    .font(.body)
                    .fontDesign(.monospaced)
                    .padding(.vertical, 4)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(4)
        }
        .frame(maxWidth: .infinity)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if let name = fetcher.paste?.name {
                    ThemedTextView(text: "/\(name)")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if let content = fetcher.paste?.content {
                        ShareLink(item: content)
                        Button(action: {
                            UIPasteboard.general.string = content
                        }, label: {
                            Label(
                                title: { Text("Copy Content") },
                                icon: { Image(systemName: "doc.on.doc") }
                            )
                        })
                    }
                    Divider()
                    if let shareItem = fetcher.paste?.shareURLs.first {
                        ShareLink(shareItem.name, item: shareItem.content)
                        Button(action: {
                            UIPasteboard.general.string = shareItem.content.absoluteString
                        }, label: {
                            Label(
                                title: { Text("Copy URL") },
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
