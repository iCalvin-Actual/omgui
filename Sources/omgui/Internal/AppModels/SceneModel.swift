//
//  File.swift
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
    
    private var authenticationFetcher: AccountAuthDataFetcher?
    
    // App Storage
    @Binding
    @ObservationIgnored
    var authKey: String
    @Binding
    @ObservationIgnored
    var localBlockedAddresses: String
    @Binding
    @ObservationIgnored
    var currentlyPinnedAddresses: String
    @Binding
    @ObservationIgnored
    var localAddressesCache: String
    @Binding
    @ObservationIgnored
    var myName: String
    
    // Scene Storage
    @Binding
    @ObservationIgnored
    var actingAddress: AddressName
    
    let fetchConstructor: FetchConstructor
    
    var globalBlockedFetcher: AddressBlockListDataFetcher
    var addressBlockedFetcher: AddressBlockListDataFetcher
    var addressFollowingFetcher: AddressFollowingDataFetcher
    
    var following: [AddressName] {
        addressFollowingFetcher.results.map({ $0.addressName })
    }
    
    @ObservationIgnored
    var requests: [AnyCancellable] = []
    
    var destinationConstructor: DestinationConstructor {
        .init(
            sceneModel: self
        )
    }
    
    // MARK: Blocklists
    
    var localBlocklist: [AddressName] {
        get {
            let split = localBlockedAddresses.split(separator: "&&&")
            return split.map({ String($0) })
        }
        set {
            localBlockedAddresses = Array(Set(newValue)).joined(separator: "&&&")
        }
    }
    var globalBlocklist: [AddressName] {
        globalBlockedFetcher.results.map({ $0.addressName })
    }
    
    func unblock(_ address: AddressName) {
        if signedIn {
            addressBlockedFetcher.unBlock(address, credential: authKey)
        }
        localBlocklist.removeAll(where: { $0 == address })
    }
    func block(_ address: AddressName) {
        if signedIn {
            addressBlockedFetcher.block(address, credential: authKey)
        }
        localBlocklist.append(address)
    }
    
    public var myAddresses: [String] {
        get {
            localAddressesCache.split(separator: "&&&").map({ String($0) })
        }
        set {
            localAddressesCache = newValue.joined(separator: "&&&")
        }
    }
    public var myOtherAddresses: [String] {
        myAddresses.filter({ $0 != actingAddress })
    }
    
    var pinnedAddresses: [AddressName] {
        get {
            let split = currentlyPinnedAddresses.split(separator: "&&&")
            return split.map({ String($0) })
        }
        set {
            currentlyPinnedAddresses = Array(Set(newValue)).joined(separator: "&&&")
        }
    }
    func isPinned(_ address: AddressName) -> Bool {
        pinnedAddresses.contains(address)
    }
    func pin(_ address: AddressName) {
        pinnedAddresses.append(address)
    }
    func removePin(_ address: AddressName) {
        pinnedAddresses.removeAll(where: { $0 == address })
    }
    
    
    var publicProfileCache: [AddressName: AddressSummaryDataFetcher] = [:]
    var privateProfileCache: [AddressName: AddressPrivateSummaryDataFetcher] = [:]
    
    var signedIn: Bool {
        !authKey.isEmpty
    }
    
    init(
        fetchConstructor: FetchConstructor,
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
        self._currentlyPinnedAddresses = pinnedAddresses
        self._localAddressesCache = myAddresses
        self._myName = myName
        self._actingAddress = actingAddress
        self.fetchConstructor = fetchConstructor
        self.globalBlockedFetcher = AddressBlockListDataFetcher(address: "app", credential: nil, interface: fetchConstructor.interface, db: fetchConstructor.database)
        self.globalBlockedFetcher = AddressBlockListDataFetcher(address: "app", credential: nil, interface: fetchConstructor.interface, db: fetchConstructor.database)
        self.addressBlockedFetcher = AddressBlockListDataFetcher(address: actingAddress.wrappedValue, credential: authKey.wrappedValue, interface: fetchConstructor.interface, db: fetchConstructor.database)
        self.addressFollowingFetcher = AddressFollowingDataFetcher(address: actingAddress.wrappedValue, credential: authKey.wrappedValue, interface: fetchConstructor.interface, db: fetchConstructor.database)
        self.authenticationFetcher = AccountAuthDataFetcher(sceneModel: self)
    }
    
    public func credential(for address: AddressName) -> APICredential? {
        guard !authKey.isEmpty, myAddresses.contains(address) else {
            return nil
        }
        return authKey
    }
    
    public func authenticate() {
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

extension SceneModel {
    private func constructFetcher(for address: AddressName) -> AddressSummaryDataFetcher {
        fetchConstructor.addressDetailsFetcher(address)
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
    private func constructPrivateFetcher(for address: AddressName) -> AddressPrivateSummaryDataFetcher? {
        guard let credential = credential(for: address) else {
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
    public func isFollowing(_ address: AddressName) -> Bool {
        guard signedIn else {
            return false
        }
        return following.contains(address)
    }
    public func canFollow(_ address: AddressName) -> Bool {
        guard signedIn else {
            return false
        }
        return !following.contains(address)
    }
    public func canUnFollow(_ address: AddressName) -> Bool {
        guard signedIn else {
            return false
        }
        return following.contains(address)
    }
    public func follow(_ address: AddressName) {
        guard let credential = credential(for: actingAddress) else {
            return
        }
        addressFollowingFetcher.follow(address, credential: credential)
    }
    public func unFollow(_ address: AddressName) {
        guard let credential = credential(for: address) else {
            return
        }
        addressFollowingFetcher.unFollow(address, credential: credential)
    }
    
    var applicableBlocklist: [AddressName] {
        Array(Set(globalBlocklist + localBlocklist))
    }
    var viewableBlocklist: [AddressName] {
        localBlocklist
    }
    func isBlocked(_ address: AddressName) -> Bool {
        applicableBlocklist.contains(address)
    }
    func canUnblock(_ address: AddressName) -> Bool {
        viewableBlocklist.contains(address)
    }
}
