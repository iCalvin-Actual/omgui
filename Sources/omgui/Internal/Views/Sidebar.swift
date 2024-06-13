//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

@MainActor
struct Sidebar: View {
    
    @Environment(\.horizontalSizeClass)
    var horizontalSize
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    @State
    var expandAddresses: Bool = false
    
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
            List(selection: $selected) {
                ForEach(sidebarModel.sections) { section in
                    let items = sidebarModel.items(for: section)
                    if !items.isEmpty {
                        Section {
                            ForEach(items) { item in
                                item.sidebarView
                                    .tag(item)
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
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationDestination(for: NavigationDestination.self, destination: destinationView(_:))
        .safeAreaInset(edge: .top) {
            if sidebarModel.addressBook.accountModel.signedIn {
                if !expandAddresses {
                    activeAddressLabel
                } else {
                    VStack(alignment: .trailing) {
                        activeAddressLabel
                        ForEach(sidebarModel.addressBook.myAddresses) { address in
                            if address != sidebarModel.actingAddress {
                                HStack {
                                    Button {
                                        withAnimation {
                                            expandAddresses = false
                                            sidebarModel.addressBook.setActiveAddress(address)
                                        }
                                    } label: {
                                        ThemedTextView(text: address.addressDisplayString)
                                            .padding(.horizontal)
                                    }
                                    Spacer()
                                }
                                .padding(.leading)
                            }
                        }
                        Button {
                            self.showConfirmLogout.toggle()
                        } label: {
                            Text("Sign out")
                                .bold()
                                .font(.callout)
                                .fontDesign(.serif)
                                .padding(3)
                        }
                        .accentColor(.red)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.roundedRectangle(radius: 6))
                        .padding(.horizontal)
                    }
                }
            } else {
                Button {
                    DispatchQueue.main.async {
                        Task {
                            await sidebarModel.addressBook.accountModel.authenticate()
                        }
                    }
                } label: {
                    Label {
                        Text("sgn in")
                    } icon: {
                        Image("prami", bundle: .module)
                            .resizable()
                            .frame(width: 33, height: 33)
                    }
                }
                .bold()
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.lolRandom())
                .cornerRadius(16)
                .padding(.horizontal)
            }
        }
        .safeAreaInset(edge: .bottom, content: {
            if !sidebarModel.addressBook.accountModel.signedIn {
                Button {
                    selected = .account
                } label: {
                    Label {
                        Text("mre abt omg.lol")
                    } icon: {
                        Image("prami", bundle: .module)
                            .resizable()
                            .frame(width: 33, height: 33)
                    }
                }
                .bold()
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.lolRandom())
                .cornerRadius(16)
                .padding(.horizontal)
            }
        })
        .alert("Logout", isPresented: $showConfirmLogout) {
            Button("Cancel", role: .cancel) { }
            Button("Yes", role: .destructive) {
                Task {
                    await sidebarModel.addressBook.accountModel.logout()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                ThemedTextView(text: "app.lol")
            }
        }
    }
    
    @ViewBuilder
    var activeAddressLabel: some View {
        ListRow<AddressModel>(
            model: .init(name: sidebarModel.actingAddress),
            preferredStyle: .minimal
        )
        .padding(.horizontal)
        .padding(.top)
        .onTapGesture {
            withAnimation {
                expandAddresses.toggle()
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
    
    @ViewBuilder
    func destinationView(_ destination: NavigationDestination? = .webpage("app")) -> some View {
            sceneModel.destinationConstructor.destination(destination)
                .navigationDestination(for: NavigationDestination.self, destination: sceneModel.destinationConstructor.destination(_:))
    }
}
