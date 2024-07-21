//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 4/26/23.
//

import SwiftData
import SwiftUI

struct PURLView: View {
    @Environment(\.horizontalSizeClass)
    var sizeClass
    @Environment(\.viewContext)
    var context: ViewContext
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    @State
    var active: URL?
    
    let address: AddressName
    let title: String
    
    @Query
    var purls: [AddressPURLModel]
    var purl: AddressPURLModel? {
        purls.first(where: { $0.owner == address && $0.title == title })
    }
    
    var body: some View {
        content
            .onAppear(perform: {
                Task {
                    try await sceneModel.fetchPURL(address, title: title)
                }
            })
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        if let purlURL = URL(string: "https://\(address).url.lol/\(title)") {
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
                        if let shareURL = purl?.destination {
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
        EmptyView()
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
        HTMLContentView(
            activeAddress: address,
            htmlContent: nil,
            baseURL: purl?.destinationURL,
            activeURL: $active
        )
    }
    
    @ViewBuilder
    var overlay: some View {
        VStack(alignment: .leading, spacing: 0) {
            if context != .profile {
                HStack(alignment: .top) {
                    Spacer()
                    ThemedTextView(text: address.addressDisplayString)
                    Menu {
                        Text("Context menu")
//                        AddressModel(name: address).contextMenu(in: sceneModel)
                    } label: {
                        AddressIconView(address: address)
                    }
                    .padding(.trailing)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Group {
                    switch sizeClass {
                    case .compact:
                        if !title.isEmpty {
                            Text("/\(title)")
                                .font(.title3)
                                .foregroundStyle(Color.primary)
                        }
                    default:
                        Text("\(address).purl.lol/")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Color.accentColor)
                        +
                        Text(title)
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
                
                if let destination = purl?.destination {
                    Text(destination)
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
