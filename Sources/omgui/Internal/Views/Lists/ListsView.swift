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
    @Environment(AccountAuthDataFetcher.self)
    var accountFetcher
    
    init(sceneModel: SceneModel) {
        viewModel = .init(sceneModel: sceneModel)
    }
    
    var body: some View {
        List(selection: $selected) {
            Section("Pinned") {
                if viewModel.showPinned {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top) {
                            ForEach(viewModel.pinned) { address in
                                NavigationLink(value: NavigationDestination.address(address)) {
                                    VStack(alignment: .leading) {
                                        AddressIconView(address: address, size: 80)
                                            .padding(4)
                                        Text(address.addressDisplayString)
                                            .font(.headline)
                                            .fontDesign(.serif)
                                            .multilineTextAlignment(.trailing)
                                            .lineLimit(3)
                                            .foregroundStyle(Color.primary)
                                    }
                                    .frame(width: 88)
                                }
                            }
                        }
                    }
                    .overlay(alignment: .topLeading, content: {
                        Image(systemName: "pin.square.fill")
                            .font(.subheadline)
                            .foregroundStyle(Color.accentColor)
                    })
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
                    if viewModel.showFollowing {
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
            
            ForEach(viewModel.sidebarModel.sectionsForLists) { section in
                Section(section.displayName) {
                    ForEach(viewModel.sidebarModel.items(for: section)) { item in
                        NavigationLink {
                            sceneModel.destinationConstructor.destination(item.destination)
                        } label: {
                            item.label
                        }
                    }
                }
            }
            
            if sceneModel.addressBook.signedIn {
                Button {
                    Task { [accountFetcher] in
                        accountFetcher.logout()
                    }
                } label: {
                    Label {
                        Text("Sign out")
                    } icon: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: 4) {
                    LogoView()
                        .frame(height: 34)
                    ThemedTextView(text: "app.lol", font: .title)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

@MainActor
class ListsViewModel: ObservableObject {
    let sidebarModel: SidebarModel
    
    var showPinned: Bool { !pinned.isEmpty }
    var showFollowing: Bool { !following.isEmpty }
    var showBlocked: Bool { !blocked.isEmpty }
    
    init(sceneModel: SceneModel) {
        self.sidebarModel = .init(sceneModel: sceneModel)
    }
    
    var sceneModel: SceneModel {
        sidebarModel.sceneModel
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

#Preview {
    let sceneModel = SceneModel.sample
    let accountAuthFetcher = AccountAuthDataFetcher(authKey: nil, client: .sample, interface: sceneModel.interface)
    ListsView(sceneModel: sceneModel)
        .environment(sceneModel)
        .environment(accountAuthFetcher)
    
}
