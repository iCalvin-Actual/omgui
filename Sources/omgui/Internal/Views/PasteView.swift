//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 4/26/23.
//

import SwiftData
import SwiftUI

struct PasteView: View {
    @Environment(SceneModel.self)
    var sceneModel
    
    let address: AddressName
    let title: String
    
    @Query
    var pastes: [AddressPasteModel]
    var paste: AddressPasteModel? {
        pastes.first(where: { $0.owner == address && $0.title == title })
    }
    
    var body: some View {
        mainContent
            .onAppear {
                Task {
                    try await sceneModel.fetchPaste(address, title: title)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if let name = paste?.title {
                        ThemedTextView(text: "/\(name)")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        if let content = paste?.content {
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
//                        Divider()
//                        if let shareItem = paste?.shareURLs.first {
//                            ShareLink(shareItem.name, item: shareItem.content)
//                            Button(action: {
//                                UIPasteboard.general.string = shareItem.content.absoluteString
//                            }, label: {
//                                Label(
//                                    title: { Text("Copy URL") },
//                                    icon: { Image(systemName: "link") }
//                                )
//                            })
//                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
    }
    
    @ViewBuilder
    var mainContent: some View {
        VStack(alignment: .leading) {
            Group {
                Text("\(address).paste.lol/")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color.accentColor)
                +
                Text(paste?.title ?? title)
                    .font(.title3)
                    .foregroundStyle(Color.primary)
            }
            .fontDesign(.monospaced)
            .padding(.top)
            .padding(.horizontal)
            
            ScrollView {
                Text(paste?.content ?? "")
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
    }
}
