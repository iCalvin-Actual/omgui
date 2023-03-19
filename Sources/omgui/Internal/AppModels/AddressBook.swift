//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/18/23.
//

import Combine
import SwiftUI


class AddressBook: DataFetcher {
    @SceneStorage("app.lol.active")
    var preferredAddress: AddressName = ""
    
    var actingAddress: AddressName = "" {
        didSet {
            guard oldValue != actingAddress else { return }
            fetchForAddress()
            self.threadSafeSendUpdate()
        }
    }
    
    let accountModel: AccountModel
    
    let fetchConstructor: FetchConstructor
    
    init(accountModel: AccountModel, fetchConstructor: FetchConstructor) {
        let interface = fetchConstructor.interface
        self.accountModel = accountModel
        self.fetchConstructor = fetchConstructor
        
        self.directoryFetcher = fetchConstructor.addressDirectoryDataFetcher()
        self.gardenFetcher = fetchConstructor.nowGardenFetcher()
        self.statusLogFetcher = fetchConstructor.generalStatusLog()
        self.globalBlocklistFetcher = fetchConstructor.blockListFetcher(for: "app", credential: nil)
        self.localBloclistFetcher = LocalBlockListDataFetcher(interface: interface)
        self.pinnedAddressFetcher = PinnedListDataFetcher(interface: interface)
        
        self.blocklistFetcher = BlockListDataFetcher(
            globalFetcher: globalBlocklistFetcher,
            localFetcher: localBloclistFetcher,
            addressFetcher: nil,
            interface: interface
        )
        
        super.init(interface: interface)
        
        accountModel.objectWillChange.sink { _ in
            Task {
                await self.update()
            }
        }
        .store(in: &requests)
    }
    
    override func throwingUpdate() async throws {
        myAddressesFetcher = AccountAddressDataFetcher(interface: fetchConstructor.interface, credential: accountModel.authKey)
        myAddressesFetcher?.objectWillChange.sink { _ in
            self.handleAddresses(self.myAddresses)
        }
        .store(in: &requests)
        
        fetchForAddress()
    }
    
    func fetchForAddress() {
        blocklistFetcher = constructBlocklist()
        blocklistFetcher.objectWillChange.sink { _ in
            self.threadSafeSendUpdate()
        }
        .store(in: &requests)
        
        followingFetcher = nil
        followingStatusLogFetcher = nil
        let followingFetcher = addressSummary(actingAddress).followingFetcher
        followingFetcher.objectWillChange.sink { _ in
            self.followingStatusLogFetcher = self.fetchConstructor.statusLog(for: self.following)
            Task {
                await self.followingStatusLogFetcher?.update()
            }
            self.threadSafeSendUpdate()
        }
        .store(in: &requests)
        self.followingFetcher = followingFetcher
        Task {
            await followingFetcher.update()
        }
    }
    
    public func handleAddresses(_ incomingAddresses: [AddressName]) {
        incomingAddresses.forEach { address in
            publicProfileCache[address] = constructFetcher(for: address)
        }
        guard !incomingAddresses.isEmpty else {
            return
        }
        guard actingAddress.isEmpty || !incomingAddresses.contains(actingAddress) else {
            return
        }
        let firstAddress = incomingAddresses.first!
        let preference = self.myAddresses.contains(self.preferredAddress) ? self.preferredAddress : firstAddress
        self.setActiveAddress(preference)
    }
    
    public func setActiveAddress(_ address: AddressName) {
        if !address.isEmpty {
            preferredAddress = address
        }
        actingAddress = address
    }
    
    public let directoryFetcher: AddressDirectoryDataFetcher
    public let gardenFetcher: NowGardenDataFetcher
    public let statusLogFetcher: StatusLogDataFetcher
    
    private var publicProfileCache: [AddressName: AddressSummaryDataFetcher] = [:]
    private func constructFetcher(for address: AddressName) -> AddressSummaryDataFetcher {
        fetchConstructor.addressDetailsFetcher(address, credential: accountModel.credential(for: address, in: self))
    }
    public func addressSummary(_ address: AddressName) -> AddressSummaryDataFetcher {
        if let model = publicProfileCache[address] {
            return model
        } else {
            let model = constructFetcher(for: address)
            publicProfileCache[address] = model
            return model
        }
    }
    
    var followingFetcher: AddressFollowingDataFetcher?
    public var following: [AddressName] {
        followingFetcher?.listItems.map({ $0.name }) ?? []
    }
    public func isFollowing(_ address: AddressName) -> Bool {
        guard accountModel.signedIn else {
            return false
        }
        return following.contains(address)
    }
    public func canFollow(_ address: AddressName) -> Bool {
        guard accountModel.signedIn else {
            return false
        }
        return !following.contains(address)
    }
    public func canUnFollow(_ address: AddressName) -> Bool {
        guard accountModel.signedIn else {
            return false
        }
        return following.contains(address)
    }
    public func follow(_ address: AddressName) {
        guard let fetcher = followingFetcher, let credential = accountModel.credential(for: actingAddress, in: self) else {
            return
        }
        fetcher.follow(address, credential: credential)
    }
    public func unFollow(_ address: AddressName) {
        guard let fetcher = followingFetcher, let credential = accountModel.credential(for: actingAddress, in: self) else {
            return
        }
        fetcher.unFollow(address, credential: credential)
    }
    var followingStatusLogFetcher: StatusLogDataFetcher?
    
    public var blocklistFetcher: BlockListDataFetcher
    
    private let globalBlocklistFetcher: AddressBlockListDataFetcher
    private var globalBlocked: [AddressName] {
        globalBlocklistFetcher.listItems.map { $0.name }
    }
    private let localBloclistFetcher: LocalBlockListDataFetcher
    private var localBlocked: [AddressName] {
        localBloclistFetcher.listItems.map { $0.name }
    }
    
    private var addressBlocked: [AddressName] {
        blocklistFetcher.addressBlocklistFetcher?.listItems.map { $0.name } ?? []
    }
    public func constructBlocklist() -> BlockListDataFetcher {
        return BlockListDataFetcher(
            globalFetcher: globalBlocklistFetcher,
            localFetcher: localBloclistFetcher,
            addressFetcher: addressSummary(actingAddress).blockedFetcher,
            interface: interface
        )
    }
    
    var applicableBlocklist: [AddressName] {
        Array(Set(globalBlocked + localBlocked + addressBlocked))
    }
    var viewableBlocklist: [AddressName] {
        Array(Set(localBlocked + addressBlocked))
    }
    func isBlocked(_ address: AddressName) -> Bool {
        applicableBlocklist.contains(address)
    }
    func canUnblock(_ address: AddressName) -> Bool {
        viewableBlocklist.contains(address)
    }
    func block(_ address: AddressName) {
        if let addressFetcher = blocklistFetcher.addressBlocklistFetcher, let credential = accountModel.credential(for: actingAddress, in: self) {
            addressFetcher.block(address, credential: credential)
        }
        localBloclistFetcher.insert(address)
    }
    func unblock(_ address: AddressName) {
        if let addressFetcher = blocklistFetcher.addressBlocklistFetcher, let credential = accountModel.credential(for: actingAddress, in: self) {
            addressFetcher.unBlock(address, credential: credential)
        }
        localBloclistFetcher.remove(address)
    }
    
    let pinnedAddressFetcher: PinnedListDataFetcher
    var pinned: [AddressName] {
        pinnedAddressFetcher.listItems.map { $0.name }
    }
    
    private var myAddressesFetcher: AccountAddressDataFetcher?
    var myAddresses: [AddressName] {
        myAddressesFetcher?.listItems.map { $0.name } ?? []
    }
    
    func isPinned(_ address: AddressName) -> Bool {
        pinned.contains(address)
    }
    func pin(_ address: AddressName) {
        pinnedAddressFetcher.pin(address)
    }
    func removePin(_ address: AddressName) {
        pinnedAddressFetcher.removePin(address)
    }
}
