//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/16/23.
//

import Combine
import SwiftUI


class AddressBookModel: DataFetcher {
    @Published
    var address: AddressName? {
        didSet {
            print("Did Set Address")
        }
    }
    
    @ObservedObject
    var appModel: AppModel
    
    let fetchConstructor: FetchConstructor
    
    @ObservedObject
    var directoryFetcher: AddressDirectoryDataFetcher
    @ObservedObject
    var blockFetcher: BlockListDataFetcher
    @ObservedObject
    var pinnedFetcher: PinnedListDataFetcher
    var followingFetcher: AddressFollowingDataFetcher?
    
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
        self.appModel = appModel
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
            self.followingFetcher = fetchConstructor.followingFetcher(for: address, credential: appModel.accountModel.credential(for: address))
            self.myAddressesFetcher = fetchConstructor.accountAddressesDataFetcher(appModel.accountModel.authKey)
        } else { self.followingFetcher = nil }
        
        super.init(interface: fetchConstructor.interface)
        
        appModel.$accountModel.sink { model in
            self.myAddressesFetcher = self.fetchConstructor.accountAddressesDataFetcher(model.authKey)
            self.myAddressesFetcher?.$listItems.sink { myItems in
                if self.actingAddress.isEmpty && !myItems.isEmpty {
                    self.updateAddress(myItems.first?.name ?? "")
                }
                self.threadSafeSendUpdate()
            }
            .store(in: &self.requests)
        }
        .store(in: &requests)
        
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
        myAddressesFetcher?.$listItems.sink { myAddresses in
            self.threadSafeSendUpdate()
        }
        .store(in: &requests)
    }
    
    private func updateAddress(_ newValue: AddressName) {
        print("IN UPDATE ADDRESS \(newValue)")
        guard !newValue.isEmpty else {
            actingAddress = ""
            followingFetcher = nil
            
            self.blockFetcher = BlockListDataFetcher(
                globalFetcher: fetchConstructor.globalBlocklistFetcher,
                localFetcher: LocalBlockListDataFetcher(interface: fetchConstructor.interface),
                addressFetcher: nil,
                interface: fetchConstructor.interface
            )
            blockFetcher.$listItems.sink { newBlocked in
                print("NewBlocked \(newBlocked.count)")
                self.threadSafeSendUpdate()
            }
            .store(in: &requests)
            return
        }
        self.actingAddress = newValue
        self.followingFetcher = fetchConstructor.followingFetcher(for: newValue, credential: appModel.accountModel.credential(for: newValue))
        self.blockFetcher = BlockListDataFetcher(
            globalFetcher: fetchConstructor.globalBlocklistFetcher,
            localFetcher: LocalBlockListDataFetcher(interface: fetchConstructor.interface),
            addressFetcher: appModel.addressDetails(newValue).blockedFetcher,
            interface: fetchConstructor.interface
        )
        followingFetcher?.$listItems.sink { newFollowing in
            print("NewFollowing \(newFollowing.map({ $0.name }))")
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
        .store(in: &requests)
        blockFetcher.$listItems.sink { newBlocked in
            print("NewBlocked \(newBlocked)")
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
        blockFetcher.allItems
    }
    var nonGlobalBlocklist: [AddressModel] {
        blockFetcher.listItems
    }
    
    override func throwingUpdate() async throws {
        try await super.throwingUpdate()
        
    }
    
    func isFollowed(_ address: AddressName) -> Bool {
        followingItems.map({ $0.name }).contains(address)
    }
    
    func follow(_ address: AddressName) {
        guard canFollow(address) else {
            return
        }
        followingFetcher?.follow(address, credential: appModel.accountModel.authKey)
    }
    
    func canFollow(_ address: AddressName) -> Bool {
        followingFetcher != nil && !followingItems.map({ $0.name }).contains(address)
    }
    
    func canUnfollow(_ address: AddressName) -> Bool {
        followingFetcher != nil && followingItems.map({ $0.name }).contains(address)
    }
    
    func removeFollow(_ address: AddressName) {
        guard canUnfollow(address) else {
            return
        }
        followingFetcher?.unFollow(address, credential: appModel.accountModel.authKey)
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
        blockFetcher.allItems.map({ $0.name }).contains(address)
    }
    
    func canUnblock(_ address: AddressName) -> Bool {
        !blockFetcher.globalBlocklistFetcher.listItems.map({ $0.name }).contains(address)
    }
    
    func block(_ address: AddressName) {
        blockFetcher.block(address, credential: appModel.accountModel.credential(for: actingAddress))
    }
    
    func unBlock(_ address: AddressName) {
        if !actingAddress.isEmpty, let credential = appModel.accountModel.credential(for: actingAddress) {
            blockFetcher.addressBlocklistFetcher?.unBlock(address, credential: credential)
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
