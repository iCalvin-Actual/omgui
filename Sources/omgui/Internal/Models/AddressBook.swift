//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 9/18/24.
//

import Foundation

@Observable
final class AddressBook {
    
    let apiKey: APICredential
    let actingAddress: AddressName
    
    let accountAddressesFetcher: AccountAddressDataFetcher
    
    let globalBlocklistFetcher: AddressBlockListDataFetcher
    let localBlocklistFetcher: LocalBlockListDataFetcher
    let addressBlocklistFetcher: AddressBlockListDataFetcher
    
    let addressFollowingFetcher: AddressFollowingDataFetcher
    
    let pinnedAddressFetcher: PinnedListDataFetcher
    
    var myAddresses: [AddressName] {
        accountAddressesFetcher.results.map({ $0.addressName })
    }
    var myOtherAddresses: [AddressName] {
        myAddresses.filter({ $0 != actingAddress })
    }
    var globalBlocked: [AddressName] {
        globalBlocklistFetcher.results.map({ $0.addressName })
    }
    var addressBlocked: [AddressName] {
        addressBlocklistFetcher.results.map({ $0.addressName })
    }
    var localBlocked: [AddressName] {
        localBlocklistFetcher.results.map({ $0.addressName })
    }
    var following: [AddressName] {
        addressFollowingFetcher.results.map({ $0.addressName })
    }
    var pinnedAddresses: [AddressName] {
        pinnedAddressFetcher.pinnedAddresses
    }
    var appliedBlocked: [AddressName] {
        Array(Set(globalBlocked + visibleBlocked))
    }
    var visibleBlocked: [AddressName] {
        Array(Set(addressBlocked + localBlocked))
    }
    
    init(
        authKey: APICredential,
        actingAddress: AddressName,
        accountAddressesFetcher: AccountAddressDataFetcher,
        globalBlocklistFetcher: AddressBlockListDataFetcher,
        localBlocklistFetcher: LocalBlockListDataFetcher,
        addressBlocklistFetcher: AddressBlockListDataFetcher,
        addressFollowingFetcher: AddressFollowingDataFetcher,
        pinnedAddressFetcher: PinnedListDataFetcher
    ) {
        self.apiKey = authKey
        self.actingAddress = actingAddress
        self.accountAddressesFetcher = accountAddressesFetcher
        self.globalBlocklistFetcher = globalBlocklistFetcher
        self.localBlocklistFetcher = localBlocklistFetcher
        self.addressBlocklistFetcher = addressBlocklistFetcher
        self.addressFollowingFetcher = addressFollowingFetcher
        self.pinnedAddressFetcher = pinnedAddressFetcher
    }
    
    func autoFetch() async {
        await accountAddressesFetcher.updateIfNeeded(forceReload: true)
        await globalBlocklistFetcher.updateIfNeeded(forceReload: true)
        await localBlocklistFetcher.updateIfNeeded(forceReload: true)
        await addressBlocklistFetcher.updateIfNeeded(forceReload: true)
        await addressFollowingFetcher.updateIfNeeded(forceReload: true)
        await pinnedAddressFetcher.updateIfNeeded(forceReload: true)
    }
    
    func credential(for address: AddressName) -> APICredential? {
        guard myAddresses.contains(address) else {
            return nil
        }
        return apiKey
    }
    
    var signedIn: Bool {
        !apiKey.isEmpty
    }
    
    func pin(_ address: AddressName) async {
        await pinnedAddressFetcher.pin(address)
    }
    func removePin(_ address: AddressName) async {
        await pinnedAddressFetcher.removePin(address)
    }
    
    func block(_ address: AddressName) async {
        if let credential = credential(for: actingAddress) {
            await addressBlocklistFetcher.block(address, credential: credential)
        }
        await localBlocklistFetcher.insert(address)
    }
    func unblock(_ address: AddressName) async {
        if let credential = credential(for: actingAddress) {
            await addressBlocklistFetcher.unBlock(address, credential: credential)
        }
        await localBlocklistFetcher.remove(address)
    }
    
    func follow(_ address: AddressName) async {
        guard let credential = credential(for: actingAddress) else {
            return
        }
        await addressFollowingFetcher.follow(address, credential: credential)
    }
    func unFollow(_ address: AddressName) async {
        guard let credential = credential(for: address) else {
            return
        }
        await addressFollowingFetcher.unFollow(address, credential: credential)
    }
}

@MainActor
extension AddressBook {
    func isPinned(_ address: AddressName) -> Bool {
        pinnedAddresses.contains(address)
    }
    func isBlocked(_ address: AddressName) -> Bool {
        appliedBlocked.contains(address)
    }
    func canUnblock(_ address: AddressName) -> Bool {
        visibleBlocked.contains(address)
    }
    func isFollowing(_ address: AddressName) -> Bool {
        guard signedIn else {
            return false
        }
        return following.contains(address)
    }
    func canFollow(_ address: AddressName) -> Bool {
        guard signedIn else {
            return false
        }
        return !following.contains(address)
    }
    func canUnFollow(_ address: AddressName) -> Bool {
        guard signedIn else {
            return false
        }
        return following.contains(address)
    }
}
