//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/18/23.
//

import Combine
import SwiftUI

@MainActor
class AddressBook: ListDataFetcher<AddressModel> {
    
    let actingAddress: AddressName
    
    @ObservedObject
    var accountModel: AccountModel
    
    public let directoryFetcher: AddressDirectoryDataFetcher
    public let gardenFetcher: NowGardenDataFetcher
    public let statusLogFetcher: StatusLogDataFetcher
    public var followingStatusLogFetcher: StatusLogDataFetcher?
    public var followingFetcher: AddressFollowingDataFetcher?
    public var blocklistFetcher: BlockListDataFetcher
    
    let fetchConstructor: FetchConstructor
    
    init(actingAddress: AddressName, accountModel: AccountModel, fetchConstructor: FetchConstructor) {
        let interface = fetchConstructor.interface
        self.accountModel = accountModel
        self.fetchConstructor = fetchConstructor
        self.actingAddress = actingAddress
        
        self.directoryFetcher = fetchConstructor.addressDirectoryDataFetcher()
        self.gardenFetcher = fetchConstructor.nowGardenFetcher()
        self.statusLogFetcher = fetchConstructor.generalStatusLog()
        
        self.blocklistFetcher = BlockListDataFetcher(
            globalFetcher: accountModel.globalBlocklistFetcher,
            localFetcher: accountModel.localBloclistFetcher,
            addressFetcher: nil,
            interface: interface
        )
        
        super.init(interface: interface)
        
        accountModel.objectWillChange.sink { _ in
            Task { [weak self] in
                await self?.perform()
            }
        }
        .store(in: &requests)
    }
    
    override func throwingRequest() async throws {
        blocklistFetcher = constructBlocklist()
        blocklistFetcher.objectWillChange.sink { [weak self] _ in
            guard let self = self else { return }
            self.threadSafeSendUpdate()
        }
        .store(in: &requests)
        
        followingFetcher = nil
        followingStatusLogFetcher = nil
        let followingFetcher = addressSummary(actingAddress).followingFetcher
        followingFetcher.objectWillChange.sink { [weak self] _ in
            guard let self = self else { return }
            if self.following.sorted() != self.followingStatusLogFetcher?.addresses.sorted() ?? [] {
                self.followingStatusLogFetcher = self.fetchConstructor.statusLog(for: self.following)
                self.threadSafeSendUpdate()
            }
        }
        .store(in: &requests)
        self.followingFetcher = followingFetcher
        
        Task {
            await followingFetcher.perform()
        }
    }
    
    public func handleAddresses(_ incomingAddresses: [AddressName]) {
        incomingAddresses.forEach { address in
            accountModel.publicProfileCache[address] = constructFetcher(for: address)
        }
    }
    
    public func profilePoster(for address: AddressName) -> ProfileDraftPoster? {
        try? addressPrivateSummary(address).profilePoster
    }
    
    public func nowPoster(for address: AddressName) -> NowDraftPoster? {
        try? addressPrivateSummary(address).nowPoster
    }
    
    private func constructFetcher(for address: AddressName) -> AddressSummaryDataFetcher {
        fetchConstructor.addressDetailsFetcher(address)
    }
    public func addressSummary(_ address: AddressName) -> AddressSummaryDataFetcher {
        if let model = accountModel.publicProfileCache[address] {
            return model
        } else {
            let model = constructFetcher(for: address)
            accountModel.publicProfileCache[address] = model
            return model
        }
    }
    
    private var privateProfileCache: [AddressName: AddressPrivateSummaryDataFetcher] = [:]
    private var imageCache: [AddressName: Image] = [:]
    private func constructPrivateFetcher(for address: AddressName) -> AddressPrivateSummaryDataFetcher? {
        guard let credential = accountModel.credential(for: address, in: self) else {
            return nil
        }
        return fetchConstructor.addressPrivateDetailsFetcher(address, credential: credential)
    }
    enum AddressBookError: Error {
        case notYourAddress
    }
    public func addressPrivateSummary(_ address: AddressName) throws -> AddressPrivateSummaryDataFetcher {
        if let model = privateProfileCache[address] {
            return model
        } else {
            guard let model = constructPrivateFetcher(for: address) else {
                throw AddressBookError.notYourAddress
            }
            privateProfileCache[address] = model
            return model
        }
    }
    
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
    
    private var globalBlocked: [AddressName] {
        accountModel.globalBlocklistFetcher.listItems.map { $0.name }
    }
    private var localBlocked: [AddressName] {
        accountModel.localBloclistFetcher.listItems.map { $0.name }
    }
    
    private var addressBlocked: [AddressName] {
        blocklistFetcher.addressBlocklistFetcher?.listItems.map { $0.name } ?? []
    }
    
    public func constructBlocklist() -> BlockListDataFetcher {
        return BlockListDataFetcher(
            globalFetcher: accountModel.globalBlocklistFetcher,
            localFetcher: accountModel.localBloclistFetcher,
            addressFetcher: {
                if accountModel.myAddresses.contains(actingAddress), let summary = try? addressPrivateSummary(actingAddress) {
                    return summary.blockedFetcher
                }
                return nil
            }(),
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
        accountModel.localBloclistFetcher.insert(address)
    }
    func unblock(_ address: AddressName) {
        if let addressFetcher = blocklistFetcher.addressBlocklistFetcher, let credential = accountModel.credential(for: actingAddress, in: self) {
            addressFetcher.unBlock(address, credential: credential)
        }
        accountModel.localBloclistFetcher.remove(address)
    }
    
    var pinned: [AddressName] {
        accountModel.pinnedAddressFetcher.listItems.map { $0.name }
    }
    
    var myAddresses: [AddressName] {
        let fetchedAddresses = accountModel.myAddressesFetcher?.listItems.map { $0.name } ?? []
        guard !fetchedAddresses.isEmpty else {
            return accountModel.localAddresses
        }
        return fetchedAddresses
    }
    
    func isPinned(_ address: AddressName) -> Bool {
        pinned.contains(address)
    }
    func pin(_ address: AddressName) {
        accountModel.pinnedAddressFetcher.pin(address)
    }
    func removePin(_ address: AddressName) {
        accountModel.pinnedAddressFetcher.removePin(address)
    }
    
    override var listItems: [AddressModel] {
        get { accountModel.myAddressesFetcher?.listItems ?? [] }
        set { }
    }
}
