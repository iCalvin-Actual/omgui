//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 9/1/24.
//

import SwiftUI

struct ListsView: View {
    @ObservedObject
    var viewModel: ListsViewModel
    
    @State
    var selected: NavigationItem?
    
    @Environment(SceneModel.self)
    var sceneModel
    
    init(sceneModel: SceneModel) {
        viewModel = .init(sceneModel: sceneModel)
    }
    
    var body: some View {
        List(selection: $selected) {
            Section("Pinned") {
                if viewModel.showPinned {
                    ForEach(viewModel.pinned) { address in
                        NavigationLink {
                            sceneModel.destinationConstructor.destination(.address(address))
                        } label: {
                            NavigationItem.pinnedAddress(address).label
                        }
                    }
                } else {
                    Label(title: {
                        Text("pin addresses")
                    }) {
                        Image(systemName: "pin")
                    }
                }
            }
            
            if sceneModel.addressBook.signedIn {
                Section("Following") {
                    if viewModel.showPinned {
                        ForEach(viewModel.following) { address in
                            NavigationLink {
                                sceneModel.destinationConstructor.destination(.address(address))
                            } label: {
                                Label(title: {
                                    Text(address.addressDisplayString)
                                }) {
                                    Image(systemName: "person.3")
                                }
                            }
                        }
                    } else {
                        Label(title: {
                            Text("follow addresses")
                        }) {
                            Image(systemName: "person.3")
                        }
                    }
                }
            }
            
            Section("Blocked") {
                if viewModel.showBlocked {
                    NavigationLink {
                        sceneModel.destinationConstructor.destination(.blocked)
                    } label: {
                        Label(title: { Text("blocked") }, icon: { Image(systemName: "person.slash")})
                    }
                } else {
                    Label(title: { Text("block content you don't want to see") }, icon: { Image(systemName: "person.slash")})
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationBarTitleDisplayMode(.inline)
    }
}

@MainActor
class ListsViewModel: ObservableObject {
    let sceneModel: SceneModel
    
    var showPinned: Bool { !pinned.isEmpty }
    var showFollowing: Bool { !following.isEmpty }
    var showBlocked: Bool { !blocked.isEmpty }
    
    init(sceneModel: SceneModel) {
        self.sceneModel = sceneModel
    }
    
    var pinned: [AddressName] {
        sceneModel.addressBook.pinnedAddresses
    }
    
    var following: [AddressName] {
        sceneModel.addressBook.following
    }
    
    var blocked: [AddressName] {
        sceneModel.addressBook.visibleBlocked
    }
}
