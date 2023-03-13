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
    func contextMenu(with appModel: AppModel) -> M
}

struct ContextMenuBuilder<T: Menuable> {
    @ViewBuilder
    func contextMenu(for item: T, with appModel: AppModel) -> some View {
        item.contextMenu(with: appModel)
    }
}

extension Listable where Self: Menuable {
    func contextMenu(with appModel: AppModel) -> some View {
        EmptyView()
    }
}

extension NavigationItem: Menuable {
    @ViewBuilder
    func contextMenu(with appModel: AppModel) -> some View {
        switch self {
        case .pinnedAddress(let name):
            Button(action: {
                appModel.removePin(name)
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
    func contextMenu(with appModel: AppModel) -> some View {
        Group {
            if appModel.isPinned(name) {
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
            Button(action: {
                withAnimation {
                    appModel.block(name)
                }
            }, label: {
                Label("Block", systemImage: "hand.raised")
            })
        }
    }
}
