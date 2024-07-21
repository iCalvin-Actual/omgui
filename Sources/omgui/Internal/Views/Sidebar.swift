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
    
    @State
    var expandAddresses: Bool = false
    
    @Binding
    var selected: NavigationItem?
    
    @ObservedObject
    var sidebarModel: SidebarModel
    
    private var myAddresses: [AddressName] {
        sceneModel.accountModel.myAddresses
    }
    
    init(selected: Binding<NavigationItem?>, model: SidebarModel) {
        self._selected = selected
        self.sidebarModel = model
    }
    
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
        .environment(\.viewContext, ViewContext.column)
        .navigationDestination(for: NavigationDestination.self, destination: destinationView(_:))
        .safeAreaInset(edge: .bottom) {
            AddressPicker(accountModel: sceneModel.accountModel)
        }
        .safeAreaInset(edge: .top, content: {
            if !sceneModel.accountModel.signedIn {
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
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 4) {
                    IconView()
                        .frame(height: 34)
                    ThemedTextView(text: "app.lol", font: .title)
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
