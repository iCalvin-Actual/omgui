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
    @ObservedObject
    var addressesFetcher: AccountAddressDataFetcher
    
    @State
    var selected: NavigationItem?
    
    @State
    var confirmLogout: Bool = false
    
    @SceneStorage("app.lol.address")
    var actingAddress: AddressName = ""
    
    @Environment(SceneModel.self)
    var sceneModel
    @Environment(AccountAuthDataFetcher.self)
    var accountFetcher
    @Environment(\.horizontalSizeClass)
    var sizeClass
    
    init(sceneModel: SceneModel) {
        viewModel = .init(sceneModel: sceneModel)
        addressesFetcher = sceneModel.addressBook.accountAddressesFetcher
    }
    
    var body: some View {
        List(selection: $selected) {
            Section("Lists") {
                if !viewModel.mine.isEmpty {
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top, spacing: 0) {
                                ForEach(viewModel.mine) { address in
                                    if address == sceneModel.addressBook.actingAddress {
                                        NavigationLink(value: NavigationDestination.address(address)) {
                                            previewView(for: address)
                                                .cornerRadius(10)
                                        }
                                    } else {
                                        Button {
                                            withAnimation {
                                                actingAddress = address
                                            }
                                        } label: {
                                            previewView(for: address)
                                        }
                                    }
                                }
                            }
                        }
                        .background(Material.regular)
                        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 12, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 12, style: .continuous))
                    } header: {
                        Label {
                            Text("mine")
                        } icon: {
                            Image(systemName: "person")
                        }
                        .foregroundStyle(.secondary)
                        .font(.callout)
                        .padding(.horizontal, 10)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .listRowSeparator(.hidden)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Material.ultraThin)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color.clear)
                }
                if !viewModel.following.isEmpty {
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top, spacing: 0) {
                                ForEach(viewModel.following) { address in
                                    NavigationLink(value: NavigationDestination.address(address)) {
                                        previewView(for: address)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        .background(Material.regular)
                        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 12, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 12, style: .continuous))
                    } header: {
                        Label {
                            Text("following")
                        } icon: {
                            Image(systemName: "at")
                        }
                        .foregroundStyle(.secondary)
                        .font(.callout)
                        .padding(.horizontal, 10)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .listRowSeparator(.hidden)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Material.ultraThin)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color.clear)
                }
                if viewModel.showPinned {
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top, spacing: 0) {
                                ForEach(viewModel.pinned) { address in
                                    NavigationLink(value: NavigationDestination.address(address)) {
                                        previewView(for: address)
                                    }
                                }
                                Spacer()
                            }
                        }
                        .background(Material.regular)
                        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 12, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 12, style: .continuous))
                    } header: {
                        Label {
                            Text("pinned")
                        } icon: {
                            Image(systemName: "pin")
                        }
                        .foregroundStyle(.secondary)
                        .font(.callout)
                        .padding(.horizontal, 10)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .listRowSeparator(.hidden)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Material.ultraThin)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color.clear)
                } else {
                    Label(title: {
                        Text("pin addresses here for later")
                    }) {
                        Image(systemName: "pin")
                    }
                    .foregroundStyle(.primary)
                    .listRowBackground(Color(UIColor.systemBackground).opacity(0.82))
                }
            }
            
            ForEach(viewModel.sidebarModel.sectionsForLists) { section in
                Section(section.displayName) {
                    ForEach(viewModel.sidebarModel.items(for: section, sizeClass: sizeClass, context: .detail)) { item in
                        NavigationLink {
                            sceneModel.destinationConstructor.destination(item.destination)
                        } label: {
                            item.label
                        }
                        .foregroundStyle(.primary)
                        .listRowBackground(Color(UIColor.systemBackground).opacity(0.82))
                    }
                }

            }
            
            if sceneModel.addressBook.signedIn {
                Button(
                    role: .destructive,
                    action: {
                        withAnimation {
                            confirmLogout = true
                        }
                    },
                    label: {
                        Label {
                            Text("log out")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } icon: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }
                    }
                )
                .buttonStyle(.plain)
                .listRowBackground(Color(UIColor.systemBackground).opacity(0.82))
            }
        }
        .environment(\.defaultMinListRowHeight, 0)
        .alert("log out?", isPresented: $confirmLogout, actions: {
            Button("cancel", role: .cancel) { }
            Button(
                "yes",
                role: .destructive,
                action: {
                    accountFetcher.logout()
                })
        }, message: {
            Text("are you sure you want to sign out of omg.lol?")
        })
        .safeAreaInset(edge: .bottom, content: {
            if !sceneModel.addressBook.signedIn {
                Button {
                    accountFetcher.perform()
                } label: {
                    Text("sign in with omg.lol")
                        .bold()
                        .font(.callout)
                        .fontDesign(.serif)
                        .frame(maxWidth: .infinity)
                        .padding(3)
                }
                .buttonStyle(.borderedProminent)
                .accentColor(.lolPink)
                //            .background(Color.lolPink)
                //            .foregroundStyle(Color.lolPink)
                .buttonBorderShape(.roundedRectangle(radius: 6))
                .padding(32)
            }
        })
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ThemedTextView(text: "app.lol")
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                LogoView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    func previewView(for address: AddressName) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            AddressIconView(address: address, size: 55, showMenu: false)
                .padding(4)
                .padding(.horizontal, 4)
            Text(address.addressDisplayString)
                .font(.body)
                .fontDesign(.serif)
                .foregroundStyle(Color(uiColor: UIColor.label))
                .multilineTextAlignment(.trailing)
                .lineLimit(3)
        }
        .frame(maxWidth: 88)
        .padding(8)
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
    
    var mine: [AddressName] {
        sceneModel.addressBook.myAddresses
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
        .background(Gradient(colors: Color.lolRandom))
    
}
