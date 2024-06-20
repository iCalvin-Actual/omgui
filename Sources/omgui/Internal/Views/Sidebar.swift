//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

@MainActor
struct Sidebar: View {
    
    @SceneStorage("app.lol.address")
    var actingAddress: AddressName = ""
    
    @Environment(\.horizontalSizeClass)
    var horizontalSize
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    @Environment(AddressBook.self)
    var addressBook: AddressBook
    
    @State
    var expandAddresses: Bool = false
    
    @Binding
    var selected: NavigationItem?
    
    @ObservedObject
    var sidebarModel: SidebarModel
    
    private var myAddresses: [AddressName] {
        sceneModel.accountModel.myAddresses
    }
    private var myOtherAddresses: [AddressName] {
        myAddresses.filter({ $0 != actingAddress })
    }
    
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
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .trailing, spacing: 8) {
                if addressBook.accountModel.signedIn {
                    if expandAddresses {
                        HStack(alignment: .top, spacing: 2) {
                            if !myOtherAddresses.isEmpty {
                                VStack(alignment: .leading, spacing: 2) {
                                    ForEach(myOtherAddresses) { address in
                                        Button {
                                            withAnimation {
                                                expandAddresses = false
                                                actingAddress = address
                                            }
                                        } label: {
                                            ThemedTextView(text: address.addressDisplayString)
                                                .padding(.horizontal)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .padding(.vertical, 2)
                                    }
                                }
                            } else {
                                Spacer()
                            }
                        
                            Button {
                                withAnimation {
                                    self.showConfirmLogout.toggle()
                                }
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
                            .padding(.trailing, 12)
                        }
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .bottom).combined(with: .opacity)
                            )
                        )
                    }
                    activeAddressLabel
                } else {
                    Button {
                        DispatchQueue.main.async {
                            Task {
                                expandAddresses = false
                                await sidebarModel.addressBook.accountModel.authenticate()
                            }
                        }
                    } label: {
                        Label {
                            Text("sign in")
                                .font(.title3)
                                .bold()
                                .fontDesign(.serif)
                        } icon: {
                            Image("prami", bundle: .module)
                                .resizable()
                                .frame(width: 33, height: 33)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .background(Color.lolRandom())
                    .cornerRadius(16)
                }
            }
            .padding()
            .background(Material.bar)
        }
        .safeAreaInset(edge: .top, content: {
            if !sidebarModel.addressBook.accountModel.signedIn {
                Button {
                    selected = .account
                } label: {
                    Text("more about omg.lol?")
                        .font(.title3)
                        .bold()
                        .fontDesign(.serif)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .background(Color.lolBlue)
                .cornerRadius(16)
                .padding()
                .background(Material.bar)
            }
        })
        .alert("Are you sure?", isPresented: $showConfirmLogout, actions: {
            Button("Cancel", role: .cancel) { }
            Button(
                "Yes",
                role: .destructive,
                action: {
                    Task {
                        await sidebarModel.addressBook.accountModel.logout()
                    }
                })
        }, message: {
            Text("Are you sure you want to sign out of omg.lol?")
        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 4) {
                    IconView()
                        .frame(height: 34)
                    ThemedTextView(text: "app.lol")
                        .foregroundStyle(
                            LinearGradient(colors: Color.lolRandom, startPoint: 0, endPoint: 1)
                        )
                }
            }
        }
        .onReceive(sceneModel.accountModel.objectWillChange, perform: { _ in
            Task { @MainActor in
                if actingAddress.isEmpty, let first = myAddresses.first {
                    actingAddress = first
                }
            }
        })
        .navigationTitle("")
    }
    
    @ViewBuilder
    var activeAddressLabel: some View {
        ListRow<AddressModel>(
            model: .init(name: actingAddress),
            preferredStyle: .minimal
        )
        .onTapGesture {
            withAnimation {
                expandAddresses.toggle()
            }
        }
    }
    
    private func isActingAddress(_ address: AddressName) -> Bool {
        actingAddress == address
    }
    
    @ViewBuilder
    private var addressPickerSection: some View {
        if !myAddresses.isEmpty {
            Section {
                ForEach(myAddresses) { address in
                    Button {
                        Task {
                            actingAddress = address
                        }
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
