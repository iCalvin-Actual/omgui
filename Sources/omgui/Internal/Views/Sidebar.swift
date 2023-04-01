//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct Sidebar: View {
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
        if sidebarModel.addressBook.accountModel.signedIn {
            ZStack {
                NavigationLink(value: NavigationDestination.address(sidebarModel.actingAddress)) {
                    EmptyView()
                }
                .opacity(0)
                
                ListRow<AddressModel>(model: .init(name: sidebarModel.actingAddress), preferredStyle: .minimal)
            }
        } else {
            HStack {
                Button("omg.lol sign in") {
                    DispatchQueue.main.async {
                        Task {
                            await sidebarModel.addressBook.accountModel.authenticate()
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
                                        item.contextMenu(with: sidebarModel.addressBook)
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
                sidebarModel.addressBook.accountModel.logout()
            }
        }
        .toolbar {
            if sidebarModel.addressBook.accountModel.signedIn {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        addressPickerSection
                        
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
    
    private func isActingAddress(_ address: AddressName) -> Bool {
        sidebarModel.addressBook.actingAddress == address
    }
    
    @ViewBuilder
    private var addressPickerSection: some View {
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
    
    @ViewBuilder
    private func addressOption(_ address: AddressName) -> some View {
        if isActingAddress(address) {
            Label(address, systemImage: "checkmark")
        } else {
            Label(title: { Text(address) }, icon: { EmptyView() })
        }
    }
}
