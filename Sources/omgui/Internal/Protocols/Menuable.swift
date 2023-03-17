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
        if shareURLs.count > 1 {
            Menu {
                ForEach(shareURLs) { option in
                    shareLink(option)
                }
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        } else if let option = shareURLs.first {
            shareLink(option)
        }
    }
    
    @ViewBuilder
    private func shareLink(_ option: SharePacket) -> some View {
        ShareLink(item: option.content) {
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
                sceneModel.addressBook.removePin(name)
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
        let isBlocked = sceneModel.addressBook.isBlocked(name)
        let isPinned = sceneModel.addressBook.isPinned(name)
        Group {
            if !isBlocked {
                if isPinned {
                    Button(action: {
                        withAnimation {
                            sceneModel.addressBook.removePin(name)
                        }
                    }, label: {
                        Label("Un-Pin", systemImage: "pin.slash")
                    })
                } else {
                    Button(action: {
                        withAnimation {
                            sceneModel.addressBook.pin(name)
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
                            sceneModel.addressBook.block(name)
                        }
                    }, label: {
                        Label("Block", systemImage: "eye.slash.circle")
                    })
                    
                    reportButton()
                } label: {
                    Label("Safety", systemImage: "hand.raised")
                }
            } else {
                if sceneModel.addressBook.canUnblock(name) {
                    Button(action: {
                        withAnimation {
                            sceneModel.addressBook.unBlock(name)
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
