//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/16/23.
//

import Combine
import SwiftUI


class AddressBookModel: DataFetcher {
    let address: AddressName?
    let fetchConstructor: FetchConstructor
    
    @ObservedObject
    var directoryFetcher: AddressDirectoryDataFetcher
    @ObservedObject
    var blockFetcher: BlockListDataFetcher
    @ObservedObject
    var pinnedFetcher: PinnedListDataFetcher
    var followingFetcher: ListDataFetcher<AddressModel>?
    
    var myAddressesFetcher: AccountAddressDataFetcher?
    
    var actingAddress: AddressName = ""
    
    var requests: [AnyCancellable] = []
    
    var primaryFetcher: ListDataFetcher<AddressModel> {
        let fetcher: ListDataFetcher<AddressModel> = {
            if pinnedItems.count > 0 {
                return pinnedFetcher
            }
            if followingItems.count > 0, let following = followingFetcher {
                return following
            }
            return directoryFetcher
        }()
        
        return fetcher
    }
    
    init(address: AddressName? = nil, appModel: AppModel) {
        self.address = address
        self.fetchConstructor = appModel.fetchConstructor
        
        self.directoryFetcher = fetchConstructor.directoryFetcher
        var addressFetcher: AddressBlockListDataFetcher?
        if let address = address {
            addressFetcher = appModel.addressDetails(address).blockedFetcher
        }
        
        self.blockFetcher = BlockListDataFetcher(
            globalFetcher: fetchConstructor.globalBlocklistFetcher,
            localFetcher: LocalBlockListDataFetcher(interface: fetchConstructor.interface),
            addressFetcher: addressFetcher,
            interface: fetchConstructor.interface
        )
        self.pinnedFetcher = PinnedListDataFetcher(interface: appModel.interface)
        if let address = address, !address.isEmpty {
            self.followingFetcher = fetchConstructor.followingFetcher(for: address)
            self.myAddressesFetcher = fetchConstructor.accountAddressesDataFetcher(appModel.accountModel.authKey)
        } else { self.followingFetcher = nil }
        
        super.init(interface: fetchConstructor.interface)
        
        pinnedFetcher.$listItems.sink { newPinned in
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
        .store(in: &requests)
        followingFetcher?.$listItems.sink { newFollowing in
            print("NewFollowing \(newFollowing.count)")
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
        .store(in: &requests)
        blockFetcher.$listItems.sink { newBlocked in
            print("NewBlocked \(newBlocked.count)")
            self.threadSafeSendUpdate()
        }
        .store(in: &requests)
    }
    
    var directoryItems: [AddressModel] {
        fetchConstructor.directoryFetcher.listItems
    }
    var pinnedItems: [AddressModel] {
        pinnedFetcher.listItems
    }
    var followingItems: [AddressModel] {
        followingFetcher?.listItems ?? []
    }
    var blockedItems: [AddressModel] {
        blockFetcher.listItems
    }
    var nonGlobalBlocklist: [AddressModel] {
        let local = blockFetcher.localBloclistFetcher?.listItems ?? []
        let address = blockFetcher.addressBlocklistFetcher?.listItems ?? []
        return local + address
    }
    
    override func throwingUpdate() async throws {
        try await super.throwingUpdate()
        
    }
    
    func isPinned(_ address: AddressName) -> Bool {
        pinnedFetcher.isPinned(address)
    }
    
    func pin(_ address: AddressName) {
        pinnedFetcher.pin(address)
    }
    
    func removePin(_ address: AddressName) {
        pinnedFetcher.removePin(address)
    }
    
    func isBlocked(_ address: AddressName) -> Bool {
        blockFetcher.listItems.map({ $0.name }).contains(address)
    }
    
    func canUnblock(_ address: AddressName) -> Bool {
        !blockFetcher.globalBlocklistFetcher.listItems.map({ $0.name }).contains(address)
    }
    
    func block(_ address: AddressName) {
        if !actingAddress.isEmpty {
            blockFetcher.addressBlocklistFetcher?.block(address)
        }
        blockFetcher.localBloclistFetcher?.insert(address)
    }
    
    func unBlock(_ address: AddressName) {
        if !actingAddress.isEmpty {
            blockFetcher.addressBlocklistFetcher?.unBlock(address)
        }
        blockFetcher.localBloclistFetcher?.remove(address)
        Task {
            await blockFetcher.update()
        }
    }
}

struct AddressBookView: View {
    
    @ObservedObject
    var addressBookModel: AddressBookModel
    
    @ObservedObject
    var accountModel: AccountModel
    
    var showSearch: Bool {
        !showFollowing && !showBlocklist && addressBookModel.pinnedItems.isEmpty
    }
    var showFollowing: Bool {
        accountModel.signedIn
    }
    var showBlocklist: Bool {
        !addressBookModel.nonGlobalBlocklist.isEmpty
    }
    
    var body: some View {
        ListView(
            allowSearch: showSearch,
            dataFetcher: addressBookModel.primaryFetcher,
            rowBuilder: { _ in return nil as ListRow<AddressModel>? },
            headerBuilder: {
                Group {
                    if !showSearch {
                        NavigationItem.search.sidebarView
                    }
                    if showFollowing {
                        NavigationItem.following.sidebarView
                    }
                    if showBlocklist {
                        NavigationItem.blocked.sidebarView
                    }
                }
            }
        )
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                ThemedTextView(text: "app.lol")
            }
        }
    }
}
