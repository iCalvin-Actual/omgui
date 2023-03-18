//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct Sidebar: View {
    @EnvironmentObject
    var sceneModel: SceneModel
    
    @Binding
    var selected: NavigationItem?
    
    @ObservedObject
    var sidebarModel: SidebarModel
    
    init(selected: Binding<NavigationItem?>, model: SidebarModel) {
        self._selected = selected
        self.sidebarModel = model
    }
    
    @ViewBuilder
    var accountHeader: some View {
        if sceneModel.appModel.accountModel.signedIn {
            ListRow<AddressModel>(model: .init(name: sceneModel.addressBook.actingAddress), preferredStyle: .minimal)
        } else {
            HStack {
                Button("omg.lol sign in") {
                    DispatchQueue.main.async {
                        Task {
                            await sceneModel.appModel.accountModel.authenticate()
                        }
                    }
                }
                .padding()
                .background(Color.lolRandom(Int.random(in: 0...10)))
                .cornerRadius(16)
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    @State
    var showConfirmLogout: Bool = false
    
    var body: some View {
        VStack {
            List(selection: $selected) {
                accountHeader
                ForEach(sidebarModel.sections) { section in
                    let items = sidebarModel.items(for: section)
                    if !items.isEmpty {
                        Section {
                            ForEach(items) { item in
                                item.sidebarView
                                    .contextMenu(menuItems: {
                                        item.contextMenu(with: sceneModel)
                                    })
                            }
                        } header: {
                            HStack {
                                Text(section.displayName)
                                    .fontDesign(.monospaced)
                                    .font(.subheadline)
                                    .bold()
                                Spacer()
                            }
                        }
                    }
                }
            }
            Spacer()
        }
        .alert("Logout", isPresented: $showConfirmLogout) {
            Button("Cancel", role: .cancel) { }
            Button("Yes", role: .destructive) {
                sceneModel.appModel.accountModel.logout()
            }
        }
        .toolbar {
            if sceneModel.appModel.accountModel.signedIn {
                Menu {
                    if sceneModel.appModel.accountModel.addresses.count > 1 {
                        Section {
                            ForEach(sceneModel.appModel.accountModel.addresses) { address in
                                Button {
                                    sceneModel.addressBook.updateAddress(address.name)
                                } label: {
                                    if sceneModel.addressBook.actingAddress == address.name {
                                        Label(address.name, systemImage: "checkmark")
                                    } else {
                                        Label(title: { Text(address.name)}, icon: { EmptyView() })
                                    }
                                }
                            }
                        } header: {
                            Text("Select active address")
                        }
                    }
                    
                    Button(role: .destructive) {
                        self.showConfirmLogout.toggle()
                    } label: {
                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                } label: {
                    Label("More", systemImage: "ellipsis.circle")
                }
            }
        }
    }
}
