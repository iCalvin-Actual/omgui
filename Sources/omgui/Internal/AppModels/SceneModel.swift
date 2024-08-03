//
//  SceneModel.swift
//
//
//  Created by Calvin Chestnut on 3/6/23.
//

import AuthenticationServices
import Combine
import SwiftUI

@Observable
@MainActor
class SceneModel {
    
    // MARK: Bindings
    
    @Binding @ObservationIgnored var actingAddress: AddressName
    @Binding @ObservationIgnored var authKey: String
    @Binding @ObservationIgnored var localAddressesCache: String
    @Binding @ObservationIgnored var localBlockedAddresses: String
    @Binding @ObservationIgnored var myName: String
    @Binding @ObservationIgnored var pinnedAddresses: String
    
    // MARK: DataFetchers
    
    var authenticationFetcher: AccountAuthDataFetcher?
    
    var addressBlockedFetcher: AddressBlockListDataFetcher
    var globalBlockedFetcher: AddressBlockListDataFetcher
    
    var addressFollowingFetcher: AddressFollowingDataFetcher
    
    // MARK: Caches
    
    var publicProfileCache: [AddressName: AddressSummaryDataFetcher] = [:]
    var privateProfileCache: [AddressName: AddressPrivateSummaryDataFetcher] = [:]
    
    // MARK: Properties
    
    let fetcher: FetchConstructor
    var destinationConstructor: DestinationConstructor {
        .init(
            sceneModel: self
        )
    }
    
    // MARK: Lifecycle
    
    init(
        fetcher: FetchConstructor,
        authKey: Binding<String>,
        localBlocklist: Binding<String>,
        pinnedAddresses: Binding<String>,
        myAddresses: Binding<String>,
        myName: Binding<String>,
        actingAddress: Binding<String>
    )
    {
        self._authKey = authKey
        self._localBlockedAddresses = localBlocklist
        self._pinnedAddresses = pinnedAddresses
        self._localAddressesCache = myAddresses
        self._myName = myName
        self._actingAddress = actingAddress
        self.fetcher = fetcher
        self.globalBlockedFetcher = AddressBlockListDataFetcher(address: "app", credential: nil, interface: fetcher.interface, db: fetcher.database)
        self.globalBlockedFetcher = AddressBlockListDataFetcher(address: "app", credential: nil, interface: fetcher.interface, db: fetcher.database)
        self.addressBlockedFetcher = AddressBlockListDataFetcher(address: actingAddress.wrappedValue, credential: authKey.wrappedValue, interface: fetcher.interface, db: fetcher.database)
        self.addressFollowingFetcher = AddressFollowingDataFetcher(address: actingAddress.wrappedValue, credential: authKey.wrappedValue, interface: fetcher.interface, db: fetcher.database)
        self.authenticationFetcher = AccountAuthDataFetcher(sceneModel: self)
    }
    
    // MARK: Authentication
    
    func authenticate() {
        authenticationFetcher?.perform()
    }
    func login(_ incomingAuthKey: APICredential) {
        authKey = incomingAuthKey
    }
    func logout() {
        myAddresses.forEach({ publicProfileCache.removeValue(forKey: $0) })
        myAddresses = []
        privateProfileCache = [:]
        authKey = ""
    }
}

// MARK: - AddressBook

extension SceneModel {
    enum AddressBookError: Error {
        case notYourAddress
    }
    
    // MARK: Authentication
    
    var signedIn: Bool {
        !authKey.isEmpty
    }
    var myAddresses: [String] {
        get {
            localAddressesCache
                .split(separator: "&&&")
                .map({ String($0) })
        }
        set {
            localAddressesCache = newValue.joined(separator: "&&&")
        }
    }
    var myOtherAddresses: [String] {
        myAddresses.filter({ $0 != actingAddress })
    }
    
    func credential(for address: AddressName) -> APICredential? {
        guard !authKey.isEmpty, myAddresses.contains(address) else {
            return nil
        }
        return authKey
    }
    
    // MARK: Pinned
    
    var pinned: [AddressName] {
        get {
            let split = pinnedAddresses.split(separator: "&&&")
            return split.map({ String($0) })
        }
        set {
            pinnedAddresses = Array(Set(newValue)).joined(separator: "&&&")
        }
    }
    
    func isPinned(_ address: AddressName) -> Bool {
        pinned.contains(address)
    }
    func pin(_ address: AddressName) {
        pinned.append(address)
    }
    func removePin(_ address: AddressName) {
        pinned.removeAll(where: { $0 == address })
    }
    
    // MARK: Blocked
    
    var globalBlocked: [AddressName] {
        globalBlockedFetcher.results.map({ $0.addressName })
    }
    var addressBlocked: [AddressName] {
        addressBlockedFetcher.results.map(({ $0.addressName }))
    }
    var localBlocklist: [AddressName] {
        get {
            let split = localBlockedAddresses.split(separator: "&&&")
            return split.map({ String($0) })
        }
        set {
            localBlockedAddresses = Array(Set(newValue)).joined(separator: "&&&")
        }
    }
    var applicableBlocklist: [AddressName] {
        Array(Set(globalBlocked + localBlocklist + addressBlocked))
    }
    var viewableBlocklist: [AddressName] {
        Array(Set(localBlocklist + addressBlocked))
    }
    
    func isBlocked(_ address: AddressName) -> Bool {
        applicableBlocklist.contains(address)
    }
    func canUnblock(_ address: AddressName) -> Bool {
        viewableBlocklist.contains(address)
    }
    func block(_ address: AddressName) {
        if signedIn {
            addressBlockedFetcher.block(address, credential: authKey)
        }
        localBlocklist.append(address)
    }
    func unblock(_ address: AddressName) {
        if signedIn {
            addressBlockedFetcher.unBlock(address, credential: authKey)
        }
        localBlocklist.removeAll(where: { $0 == address })
    }
    
    // MARK: Following
    
    var following: [AddressName] {
        addressFollowingFetcher.results.map({ $0.addressName })
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
    func follow(_ address: AddressName) {
        guard let credential = credential(for: actingAddress) else {
            return
        }
        addressFollowingFetcher.follow(address, credential: credential)
    }
    func unFollow(_ address: AddressName) {
        guard let credential = credential(for: address) else {
            return
        }
        addressFollowingFetcher.unFollow(address, credential: credential)
    }
    
    // MARK: Summaries
    
    func constructFetcher(for address: AddressName) -> AddressSummaryDataFetcher {
        fetcher.addressDetailsFetcher(address)
    }
    func privateSummary(for address: AddressName) -> AddressPrivateSummaryDataFetcher? {
        guard let credential = credential(for: address) else {
            return nil
        }
        return fetcher.addressPrivateDetailsFetcher(address, credential: credential)
    }
    func addressSummary(_ address: AddressName) -> AddressSummaryDataFetcher {
        if let model = publicProfileCache[address] {
            return model
        } else {
            let model = constructFetcher(for: address)
            publicProfileCache[address] = model
            return model
        }
    }
    func addressPrivateSummary(_ address: AddressName) throws -> AddressPrivateSummaryDataFetcher {
        if let model = privateProfileCache[address] {
            return model
        } else {
            guard let model = privateSummary(for: address) else {
                throw AddressBookError.notYourAddress
            }
            privateProfileCache[address] = model
            return model
        }
    }
}
