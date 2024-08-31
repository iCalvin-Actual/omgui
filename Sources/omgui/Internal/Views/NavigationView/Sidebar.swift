//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

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
    
    let sidebarModel: SidebarModel
    
    private var myAddresses: [AddressName] {
        sceneModel.addressBook.myAddresses
    }
    
    @ObservedObject
    var pinnedFetcher: PinnedListDataFetcher
    
    init(selected: Binding<NavigationItem?>, model: SidebarModel) {
        self._selected = selected
        self.sidebarModel = model
        self.pinnedFetcher = model.sceneModel.addressBook.pinnedAddressFetcher
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
                                        contextMenu(for: item)
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
//        .safeAreaInset(edge: .bottom) {
//            AddressPicker()
//        }
//        .safeAreaInset(edge: .bottom, content: {
//            if !sceneModel.addressBook.signedIn {
//                Button {
//                    selected = .account
//                } label: {
//                    Text("mor lol")
//                        .font(.title3)
//                        .bold()
//                        .fontDesign(.serif)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                }
//                .background(Color.lolBlue)
//                .cornerRadius(16)
//                .padding()
//                .background(Material.bar)
//            }
//        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 4) {
                    LogoView()
                        .frame(height: 34)
                    ThemedTextView(text: "app.lol", font: .title)
                }
            }
        }
        .navigationTitle("")
    }
    
    private func isActingAddress(_ address: AddressName) -> Bool {
        actingAddress == address
    }
    
    @ViewBuilder
    private func contextMenu(for item: NavigationItem) -> some View {
        switch item {
        case .pinnedAddress(let address):
            let addressBook = sceneModel.addressBook
            let pinnedAddressFetcher = sidebarModel.pinnedFetcher
            Button(action: {
                Task { @MainActor in
                    await addressBook.removePin(address)
                    await pinnedAddressFetcher.updateIfNeeded(forceReload: true)
                }
            }, label: {
                Label("Un-Pin \(address.addressDisplayString)", systemImage: "pin.slash")
            })
        default:
            EmptyView()
        }
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
