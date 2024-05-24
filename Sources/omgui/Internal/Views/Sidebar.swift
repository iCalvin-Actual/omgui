//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct Sidebar: View {
    
    @Environment(\.horizontalSizeClass)
    var horizontalSize
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
    
    @State
    var showConfirmLogout: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if sidebarModel.addressBook.accountModel.signedIn {
                    ZStack {
                        NavigationLink(value: NavigationDestination.address(sidebarModel.actingAddress)) {
                            EmptyView()
                        }
                        .opacity(0)
                        
                        ListRow<AddressModel>(model: .init(name: sidebarModel.actingAddress), preferredStyle: .minimal)
                    }
                }
                List(selection: $selected) {
                    ForEach(sidebarModel.sections) { section in
                        let items = sidebarModel.items(for: section)
                        if !items.isEmpty {
                            Section {
                                ForEach(items) { item in
                                    item.sidebarView
                                        .contextMenu(menuItems: {
                                            item.contextMenu(in: sceneModel)
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
            }
        }
        .alert("Logout", isPresented: $showConfirmLogout) {
            Button("Cancel", role: .cancel) { }
            Button("Yes", role: .destructive) {
                sidebarModel.addressBook.accountModel.logout()
            }
        }
        .toolbar {
            if !sidebarModel.addressBook.accountModel.signedIn {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button("omg.lol sign in") {
                            DispatchQueue.main.async {
                                Task {
                                    await sidebarModel.addressBook.accountModel.authenticate()
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.lolRandom(Int.random(in: 0...10)))
                        .cornerRadius(16)
                    }
                    .background(Color(uiColor: horizontalSize == .compact ? .systemGroupedBackground : .systemBackground))
                    .padding()
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                ThemedTextView(text: "app.lol")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if sidebarModel.addressBook.accountModel.signedIn {
                        addressPickerSection
                        
                        Button(role: .destructive) {
                            self.showConfirmLogout.toggle()
                        } label: {
                            Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } else {
                        Button {
                            DispatchQueue.main.async {
                                Task {
                                    await sidebarModel.addressBook.accountModel.authenticate()
                                }
                            }
                        } label: {
                            Label("Login", systemImage: "person.crop.circle.badge.plus")
                        }
                    }
                } label: {
                    Label("More", systemImage: "ellipsis.circle")
                }
            }
        }
    }
    
    private func isActingAddress(_ address: AddressName) -> Bool {
        sidebarModel.addressBook.actingAddress == address
    }
    
    @ViewBuilder
    private var addressPickerSection: some View {
        if !sidebarModel.addressBook.myAddresses.isEmpty {
            Section {
                ForEach(sidebarModel.addressBook.myAddresses) { address in
                    Button {
                        sidebarModel.addressBook.setActiveAddress(address)
                    } label: {
                        addressOption(address)
                    }
                }
            } header: {
                Text("Select active address")
            }
        }
    }
    
    @ViewBuilder
    private func addressOption(_ address: AddressName) -> some View {
        if isActingAddress(address) {
            Label(address, systemImage: "checkmark")
        } else {
            Label(title: { Text(address) }, icon: { EmptyView() })
        }
    }
}
