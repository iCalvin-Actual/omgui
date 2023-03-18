//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import SwiftUI
import Foundation

protocol AddressManagable {
    var addressToActOn: AddressName { get }
}

extension AddressModel: AddressManagable {
    var addressToActOn: AddressName { name }
}
extension NowListing: AddressManagable {
    var addressToActOn: AddressName { owner }
}
extension StatusModel: AddressManagable {
    var addressToActOn: AddressName { address }
}

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

extension AddressManagable where Self: Menuable {
    @ViewBuilder
    func manageSection(_ addressBook: AddressBookModel) -> some View {
        let name = addressToActOn
        let isBlocked = addressBook.isBlocked(name)
        let isPinned = addressBook.isPinned(name)
        let canFollow = addressBook.canFollow(name)
        let canUnfollow = addressBook.canUnfollow(name)
        if !isBlocked {
            if canFollow {
                Button(action: {
                    withAnimation {
                        addressBook.follow(name)
                    }
                }, label: {
                    Label("Follow", systemImage: "plus.circle")
                })
            } else if canUnfollow {
                Button(action: {
                    withAnimation {
                        addressBook.removeFollow(name)
                    }
                }, label: {
                    Label("Un-follow", systemImage: "minus.circle")
                })
            }
            
            if isPinned {
                Button(action: {
                    withAnimation {
                        addressBook.removePin(name)
                    }
                }, label: {
                    Label("Un-Pin", systemImage: "pin.slash")
                })
            } else {
                Button(action: {
                    withAnimation {
                        addressBook.pin(name)
                    }
                }, label: {
                    Label("Pin", systemImage: "pin")
                })
            }
            
            Divider()
            
            Menu {
                Button(role: .destructive, action: {
                    withAnimation {
                        addressBook.block(name)
                    }
                }, label: {
                    Label("Block", systemImage: "eye.slash.circle")
                })
                
                ReportButton()
            } label: {
                Label("Safety", systemImage: "hand.raised")
            }
        } else {
            if addressBook.canUnblock(name) {
                Button(action: {
                    withAnimation {
                        addressBook.unBlock(name)
                    }
                }, label: {
                    Label("Un-block", systemImage: "eye.circle")
                })
            }
            
            ReportButton()
        }
    }
}

extension Sharable where Self: Menuable {
    @ViewBuilder
    func shareSection() -> some View {
        if let option = primaryURL {
            shareLink(option)
        }
        if !shareURLs.isEmpty {
            Menu {
                ForEach(shareURLs) { option in
                    shareLink(option)
                }
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }
        if let option = primaryCopy {
            Button {
                UIPasteboard.general.string = option.content
            } label: {
                Label("Copy \(option.name)", systemImage: "doc.on.clipboard")
            }
        }
        if !copyText.isEmpty {
            Menu {
                ForEach(copyText) { option in
                    Button(option.name) {
                        UIPasteboard.general.string = option.content
                    }
                }
            } label: {
                Label("Copy", systemImage: "doc.on.clipboard")
            }
        }
    }
    
    @ViewBuilder
    private func shareLink(_ option: SharePacket) -> some View {
        ShareLink(item: option.content) {
            Label("Share \(option.name)", systemImage: "square.and.arrow.up")
        }
    }
    
    @ViewBuilder
    private func copyButton(_ option: CopyPacket) -> some View {
        Button {
            print("Copy")
        } label: {
            Label("Copy \(option.name)", systemImage: "doc.on.clipboard")
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
        Group {
            self.shareSection()
            Divider()
            self.manageSection(sceneModel.addressBook)
        }
    }
}

extension NowListing: Menuable {
    @ViewBuilder
    func contextMenu(with sceneModel: SceneModel) -> some View {
        Group {
            self.shareSection()
            Divider()
            self.manageSection(sceneModel.addressBook)
        }
    }
}

extension StatusModel: Menuable {
    @ViewBuilder
    func contextMenu(with sceneModel: SceneModel) -> some View {
        Group {
            self.shareSection()
            Divider()
            self.manageSection(sceneModel.addressBook)
        }
    }
}

struct ReportButton: View {
    var body: some View {
        Button(action: {
            withAnimation {
                print("Report Address Somehow")
            }
        }, label: {
            Label("Report", systemImage: "exclamationmark.bubble")
        })
    }
}
