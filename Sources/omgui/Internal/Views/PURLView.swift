//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 4/26/23.
//

import SwiftUI

struct PURLView: View {
    @Environment(\.dismiss)
    var presentation
    @Environment(\.horizontalSizeClass)
    var sizeClass
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    @Environment(\.viewContext)
    var context: ViewContext
    
    @ObservedObject
    var fetcher: AddressPURLDataFetcher
    @State
    var showDraft: Bool = false
    @State
    var detent: PresentationDetent = .draftDrawer
    @State
    var draftResult: PURLModel?
    
    var body: some View {
        mainContent(fetcher.draftPoster)
        .onReceive(fetcher.$purl, perform: { model in
            withAnimation(nil) {
                let address = fetcher.addressName
                guard sceneModel.accountModel.myAddresses.contains(address) else {
                    showDraft = false
                    return
                }
                if model == nil && fetcher.title.isEmpty {
                    detent = .large
                    showDraft = true
                } else if model != nil {
                    detent = .draftDrawer
                    showDraft = true
                }
            }
        })
        .onChange(of: draftResult, { oldValue, newValue in
            guard let newValue else {
                return
            }
            fetcher.purl = newValue
            detent = .draftDrawer
            showDraft = true
            Task { await fetcher.perform() }
        })
        .sheet(
            isPresented: $showDraft,
            onDismiss: {
                if fetcher.purl == nil {
                    presentation()
                }
            },
            content: {
                if let poster = fetcher.draftPoster {
                    PURLDraftView(draftFetcher: poster, result: $draftResult)
                    .presentationDetents(
                        fetcher.purl == nil ? [
                            .draftDrawer,
                            .large
                        ] : [
                            .draftDrawer,
                            .medium,
                            .large
                        ],
                        selection: $detent
                    )
                    .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                }
            }
        )
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if fetcher.title.isEmpty {
                    ThemedTextView(text: "/draft")
                } else {
                    ThemedTextView(text: "/\(fetcher.title)")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                if fetcher.draftPoster != nil {
                    Button {
                        withAnimation {
                            if detent == .large {
                                detent = .draftDrawer
                            } else if showDraft {
                                detent = .large
                            } else if !showDraft {
                                detent = .medium
                                showDraft = true
                            } else {
                                showDraft = false
                                detent = .draftDrawer
                            }
                        }
                    } label: {
                        Text("edit")
                    }
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
                                if !(fetcher.purl?.value.isEmpty ?? false) {
                                    Text("/\(fetcher.purl?.value ?? fetcher.title)")
                                        .font(.title3)
                                        .foregroundStyle(Color.primary)
                                }
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
                        .font(.system(size: 100))
                        .minimumScaleFactor(0.01)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .fontDesign(.monospaced)
                        .lineLimit(2)
                        
                        if let destination = fetcher.purl?.destination {
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
    
    @ViewBuilder
    var preview: some View {
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
}

public extension PresentationDetent {
    static let draftDrawer: PresentationDetent = .fraction(0.25)
}
extension PresentationDetent: @retroactive Identifiable {
    public var id: Int {
        hashValue
    }
}
