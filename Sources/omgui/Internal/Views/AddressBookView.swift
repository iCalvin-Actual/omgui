//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/16/23.
//

import Combine
import SwiftUI

struct AddressBookView: View {
    
    @ObservedObject
    var addressBook: AddressBook
    
    var accountModel: AccountModel
    
    var showSearch: Bool {
        !accountModel.signedIn && !showBlocklist && addressBook.pinned.isEmpty
    }
    var showFollowing: Bool {
        accountModel.signedIn && primaryFetcher != addressBook.followingFetcher
    }
    var showBlocklist: Bool {
        !addressBook.viewableBlocklist.isEmpty
    }
    var showPinned: Bool {
        !addressBook.pinned.isEmpty
    }
    
    var primaryFetcher: ListDataFetcher<AddressModel> {
        if addressBook.pinned.count > 0 {
            return addressBook.pinnedAddressFetcher
        }
        if addressBook.following.count > 0, let following = addressBook.followingFetcher {
            return following
        }
        return addressBook.directoryFetcher
    }
    
    @State var showConfirmLogout: Bool = false
    
    @ViewBuilder
    var accountHeader: some View {
        if accountModel.signedIn {
            ZStack {
                NavigationLink(value: NavigationDestination.address(addressBook.actingAddress)) {
                    EmptyView()
                }
                .opacity(0)
                
                ListRow<AddressModel>(model: .init(name: addressBook.actingAddress), preferredStyle: .minimal)
            }
        } else {
            HStack {
                Button("omg.lol sign in") {
                    DispatchQueue.main.async {
                        Task {
                            await accountModel.authenticate()
                        }
                    }
                }
                .padding()
                .background(Color.lolRandom())
                .cornerRadius(16)
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    @ViewBuilder
    var logoutButton: some View {
        Button {
            // Show Login
            Task {
                await accountModel.logout()
            }
        } label: {
            HStack {
                Spacer()
                Label("Logout", systemImage: "lock")
                    .padding()
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    var loggedOutHeader: some View {
        Button {
            // Show Login
            DispatchQueue.main.async {
                Task {
                    await accountModel.authenticate()
                }
            }
        } label: {
            Label("Login", systemImage: "lock.open")
        }
    }
    
    var body: some View {
        ListView(
            allowSearch: showSearch,
            allowFilter: showSearch,
            dataFetcher: primaryFetcher,
            rowBuilder: { _ in return nil as ListRow<AddressModel>? },
            headerBuilder: {
                Group {
                    if !showSearch {
                        NavigationItem.search.sidebarView
                    }
                    if showFollowing {
                        NavigationItem.followingAddresses.sidebarView
                    }
                    if showBlocklist {
                        NavigationItem.blocked.sidebarView
                    }
                    if showPinned {
                        ForEach(addressBook.pinned) { NavigationItem.pinnedAddress($0).sidebarView }
                    }
                }
            }
        )
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                ThemedTextView(text: "addresses")
            }
            if addressBook.accountModel.signedIn {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Section {
                            ForEach(addressBook.myAddresses) { address in
                                Button {
                                    addressBook.setActiveAddress(address)
                                } label: {
                                    addressOption(address)
                                }
                            }
                        } header: {
                            Text("Select active address")
                        }
                    } label: {
                        Label("More", systemImage: "chevron.down.circle")
                    }

                }
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
    
    func isActingAddress(_ addressName: AddressName) -> Bool {
        addressBook.actingAddress == addressName
    }
}
