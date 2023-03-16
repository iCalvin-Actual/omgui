//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import SwiftUI
import Foundation

protocol Menuable {
    associatedtype M: View
    func contextMenu(with sceneModel: SceneModel) -> M
}

struct ContextMenuBuilder<T: Menuable> {
    @ViewBuilder
    func contextMenu(for item: T, with sceneModel: SceneModel) -> some View {
        item.contextMenu(with: sceneModel)
    }
}

extension Sharable where Self: Menuable {
    @ViewBuilder
    func shareSection() -> some View {
        if shareItems > 1 {
            Menu {
                ForEach(shareURLs) { option in
                    shareLink(option)
                }
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        } else if let option = shareURLs.first {
            shareLink(option)
        } else if let option = shareText.first {
            shareLink(option)
        } else if let option = shareData.first {
            shareLink(option)
        }
    }
    
    @ViewBuilder
    private func shareLink<T: Transferable>(_ option: SharePacket<T>) -> some View {
        ShareLink(item: option.content, preview: SharePreview(option.content.previewText)) {
            Label("Share \(option.name)", systemImage: "square.and.arrow.up")
        }
    }
}

extension Listable where Self: Menuable {
    func contextMenu(with sceneModel: SceneModel) -> some View {
        EmptyView()
    }
}

extension NavigationItem: Menuable {
    @ViewBuilder
    func contextMenu(with sceneModel: SceneModel) -> some View {
        switch self {
        case .pinnedAddress(let name):
            Button(action: {
                sceneModel.appModel.removePin(name)
            }, label: {
                Label("Un-Pin", systemImage: "pin.slash")
            })
        default:
            EmptyView()
        }
    }
}

extension AddressModel: Menuable {
    @ViewBuilder
    func contextMenu(with sceneModel: SceneModel) -> some View {
        let isBlocked = sceneModel.isBlocked(name)
        let appModel = sceneModel.appModel
        let isPinned = appModel.isPinned(name)
        Group {
            if !isBlocked {
                if isPinned {
                    Button(action: {
                        withAnimation {
                            appModel.removePin(name)
                        }
                    }, label: {
                        Label("Un-Pin", systemImage: "pin.slash")
                    })
                } else {
                    Button(action: {
                        withAnimation {
                            appModel.pin(name)
                        }
                    }, label: {
                        Label("Pin", systemImage: "pin")
                    })
                }
                
                Divider()
                
                
                self.shareSection()
                
                Divider()
                
                Menu {
                    Button(action: {
                        withAnimation {
                            sceneModel.block(name)
                        }
                    }, label: {
                        Label("Block", systemImage: "eye.slash.circle")
                    })
                    
                    reportButton()
                } label: {
                    Label("Safety", systemImage: "hand.raised")
                }
            } else {
                if sceneModel.canUnblock(name) {
                    Button(action: {
                        withAnimation {
                            sceneModel.unBlock(name)
                        }
                    }, label: {
                        Label("Un-block", systemImage: "eye.circle")
                    })
                }
                
                reportButton()
            }
        }
    }
    
    @ViewBuilder
    private func reportButton() -> some View {
        Button(action: {
            withAnimation {
                print("Report Address Somehow")
            }
        }, label: {
            Label("Report", systemImage: "exclamationmark.bubble")
        })
    }
}
