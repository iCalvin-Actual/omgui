//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import SwiftUI
import Foundation

protocol AddressManagable {
    var owner: AddressName { get }
}

protocol Menuable {
    associatedtype M: View
    
    @MainActor
    func contextMenu(in scene: SceneModel, fetcher: Request?) -> M
}

@MainActor
extension Menuable {
    @ViewBuilder
    func editingSection(in scene: SceneModel) -> some View {
        if let editable = self as? Editable, scene.addressBook.myAddresses.contains(editable.owner) {
            NavigationLink {
                scene.destinationConstructor.destination(editable.editingDestination)
            } label: {
                Label("edit", systemImage: "pencil.line")
            }
            Divider()
        }
    }
}

@MainActor
struct ContextMenuBuilder<T: Menuable> {
    @ViewBuilder
    func contextMenu(for item: T, fetcher: Request? = nil, sceneModel: SceneModel) -> some View {
        item.contextMenu(in: sceneModel, fetcher: fetcher)
    }
}

extension AddressManagable where Self: Menuable {
    @MainActor
    @ViewBuilder
    func manageSection(_ scene: SceneModel, fetcher: Request?) -> some View {
        let name = owner
        let book = scene.addressBook
        let isBlocked = book.isBlocked(name)
        let isPinned = book.isPinned(name)
        let canFollow = book.canFollow(name)
        let canUnfollow = book.canUnFollow(name)
        if !isBlocked {
            if canFollow {
                Button(action: {
                    Task {
                        await book.follow(name)
                        await fetcher?.updateIfNeeded(forceReload: true)
                    }
                }, label: {
                    Label("Follow \(name.addressDisplayString)", systemImage: "plus.circle")
                })
            } else if canUnfollow {
                Button(action: {
                    Task {
                        await book.unFollow(name)
                        await fetcher?.updateIfNeeded(forceReload: true)
                    }
                }, label: {
                    Label("Un-follow \(name.addressDisplayString)", systemImage: "minus.circle")
                })
            }
            
            if isPinned {
                Button(action: {
                    withAnimation {
                        book.removePin(name)
                        Task {
                            await fetcher?.updateIfNeeded(forceReload: true)
                        }
                    }
                }, label: {
                    Label("Un-Pin \(name.addressDisplayString)", systemImage: "pin.slash")
                })
            } else {
                Button(action: {
                    withAnimation {
                        book.pin(name)
                        Task {
                            await fetcher?.updateIfNeeded(forceReload: true)
                        }
                    }
                }, label: {
                    Label("Pin \(name.addressDisplayString)", systemImage: "pin")
                })
            }
            
            Divider()
            
            Menu {
                Button(role: .destructive, action: {
                    Task {
                        await book.block(name)
                        await fetcher?.updateIfNeeded(forceReload: true)
                    }
                }, label: {
                    Label("Block", systemImage: "eye.slash.circle")
                })
                
                ReportButton(addressInQuestion: name)
            } label: {
                Label("Safety", systemImage: "hand.raised")
            }
        } else {
            if book.canUnblock(name) {
                Button(action: {
                    Task {
                        await book.unblock(name)
                        await fetcher?.updateIfNeeded(forceReload: true)
                    }
                }, label: {
                    Label("Un-block", systemImage: "eye.circle")
                })
            }
            
            ReportButton(addressInQuestion: name)
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
        Divider()
    }
    
    @ViewBuilder
    private func shareLink(_ option: SharePacket) -> some View {
        ShareLink(item: option.content) {
            Label("Share \(option.name)", systemImage: "square.and.arrow.up")
        }
    }
}

extension Listable where Self: Menuable {
    func contextMenu(in scene: SceneModel) -> some View {
        EmptyView()
    }
}

extension NavigationItem: Menuable {
    @ViewBuilder
    func contextMenu(in scene: SceneModel, fetcher: Request?) -> some View {
        switch self {
        case .pinnedAddress(let name):
            Button(action: {
                Task { @MainActor in
                    scene.addressBook.removePin(name)
                }
            }, label: {
                Label("Un-Pin \(name.addressDisplayString)", systemImage: "pin.slash")
            })
        default:
            EmptyView()
        }
    }
}

extension AddressModel: Menuable {
    @ViewBuilder
    @MainActor
    func contextMenu(in scene: SceneModel, fetcher: Request?) -> some View {
        Group {
            self.shareSection()
            self.editingSection(in: scene)
            self.manageSection(scene, fetcher: fetcher)
        }
    }
}

extension NowListing: Menuable {
    @ViewBuilder
    func contextMenu(in scene: SceneModel, fetcher: Request?) -> some View {
        Group {
            self.shareSection()
            self.editingSection(in: scene)
            self.manageSection(scene, fetcher: fetcher)
        }
    }
}

extension PURLModel: Menuable {
    @ViewBuilder
    func contextMenu(in scene: SceneModel, fetcher: Request?) -> some View {
        Group {
            self.shareSection()
            self.editingSection(in: scene)
            self.manageSection(scene, fetcher: fetcher)
        }
    }
}

extension PasteModel: Menuable {
    @ViewBuilder
    func contextMenu(in scene: SceneModel, fetcher: Request?) -> some View {
        Group {
            self.shareSection()
            self.editingSection(in: scene)
            self.manageSection(scene, fetcher: fetcher)
        }
    }
}

extension StatusModel: Menuable {
    @ViewBuilder
    func contextMenu(in scene: SceneModel, fetcher: Request?) -> some View {
        Group {
            self.shareSection()
            self.editingSection(in: scene)
            self.manageSection(scene, fetcher: fetcher)
        }
    }
}

struct ReportButton: View {
    var addressInQuestion: AddressName?
    
    var body: some View {
        Button(action: {
            let subject = "app.lol content report"
            let body = "/*\nPlease describe the offending behavior, provide links where appropriate.\nWe will review the offending content as quickly as we can and respond appropriately.\n */ \nOffending address: \(addressInQuestion ?? "unknown")\nmy omg.lol address: \n\n"
            let coded = "mailto:app@omg.lol?subject=\(subject)&body=\(body)"
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

            if let coded = coded, let emailURL = URL(string: coded) {
                if UIApplication.shared.canOpenURL(emailURL)
                {
                    UIApplication.shared.open(emailURL)
                }
            }
        }, label: {
            Label("Report", systemImage: "exclamationmark.bubble")
        })
    }
}
