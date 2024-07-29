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
    @Environment(\.viewContext)
    var context: ViewContext
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    @ObservedObject
    var fetcher: AddressPURLDataFetcher
    
    var body: some View {
        NamedItemView(fetcher: fetcher, mainContent: content, draftContent: draftView)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if fetcher.title.isEmpty {
                        ThemedTextView(text: "/draft")
                    } else {
                        ThemedTextView(text: "/\(fetcher.title)")
                    }
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
                        if let shareURL = fetcher.model?.content {
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
    
    @ViewBuilder
    var draftView: some View {
        if let poster = fetcher.draftPoster {
            PURLDraftView(draftFetcher: poster)
        }
    }
    
    @ViewBuilder
    func mainContent(_ poster: PURLDraftPoster?) -> some View {
        if let poster {
            content
                .onReceive(poster.$result.dropFirst(), perform: { savedResult in
                print("Stop here")
            })
        } else {
            content
        }
    }
    
    @ViewBuilder
    var content: some View {
        preview
            .safeAreaInset(edge: .top) {
                overlay
            }
    }
    
    @ViewBuilder
    var preview: some View {
        if let content = fetcher.purlContent {
            HTMLFetcherView(
                fetcher: fetcher,
                activeAddress: fetcher.addressName,
                htmlContent: content,
                baseURL: {
                    guard let destination = fetcher.model?.content else {
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
    
    @ViewBuilder
    var overlay: some View {
        VStack(alignment: .leading, spacing: 0) {
            if context != .profile {
                HStack(alignment: .top) {
                    Spacer()
                    ThemedTextView(text: fetcher.addressName.addressDisplayString)
                    Menu {
                        AddressModel(name: fetcher.addressName).contextMenu(in: sceneModel)
                    } label: {
                        AddressIconView(address: fetcher.addressName)
                    }
                    .padding(.trailing)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Group {
                    switch sizeClass {
                    case .compact:
                        if !(fetcher.model?.name.isEmpty ?? false) {
                            Text("/\(fetcher.model?.name ?? fetcher.title)")
                                .font(.title3)
                                .foregroundStyle(Color.primary)
                        }
                    default:
                        Text("\(fetcher.addressName).purl.lol/")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Color.accentColor)
                        +
                        Text(fetcher.model?.name ?? fetcher.title)
                            .font(.title3)
                            .foregroundStyle(Color.primary)
                    }
                }
                .font(.system(size: 100))
                .minimumScaleFactor(0.01)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .fontDesign(.monospaced)
                .lineLimit(2)
                
                if let destination = fetcher.model?.content {
                    Text(destination.absoluteString)
                        .textSelection(.enabled)
                        .font(.caption)
                        .fontDesign(.serif)
                        .lineLimit(2)
                }
            }
            .padding(.horizontal)
        }
    }
}

public extension PresentationDetent {
    static let draftDrawer: PresentationDetent = .fraction(0.25)
}
extension PresentationDetent: @retroactive Identifiable {
    public var id: Int {
        hashValue
    }
}
