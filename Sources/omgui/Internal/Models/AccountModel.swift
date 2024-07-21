//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Combine
import SwiftUI

@MainActor
class AccountModel: ObservableObject {
    @AppStorage("app.lol.auth", store: .standard)
    var authKey: String = ""
    
    @AppStorage("app.lol.addresses.cache", store: .standard)
    private var localAddressesCache: String = ""
    public var localAddresses: [String] {
        get {
            localAddressesCache.split(separator: "&&&").map({ String($0) })
        }
        set {
            localAddressesCache = newValue.joined(separator: "&&&")
        }
    }
    
    @AppStorage("app.lol.cache.pinned", store: .standard)
    private var currentlyPinnedAddresses: String = "adam&&&app"
    var pinnedAddresses: [AddressName] {
        get {
            let split = currentlyPinnedAddresses.split(separator: "&&&")
            return split.map({ String($0) })
        }
        set {
            currentlyPinnedAddresses = Array(Set(newValue)).joined(separator: "&&&")
            Task {
                await self.perform()
            }
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
    
    // MARK: No-Account Blocklist
    @AppStorage("app.lol.cache.blocked", store: .standard)
    private var cachedBlockList: String = ""
    var blockedAddresses: [AddressName] {
        get {
            let split = cachedBlockList.split(separator: "&&&")
            return split.map({ String($0) })
        }
        set {
            cachedBlockList = Array(Set(newValue)).joined(separator: "&&&")
            Task {
                await self.perform()
            }
        }
    }
    
    func unblock(_ address: AddressName) {
        blockedAddresses.removeAll(where: { $0 == address })
    }
    func block(_ address: AddressName) {
        blockedAddresses.append(address)
    }
    
    @ObservedObject
    private var authenticationFetcher: AccountAuthDataFetcher
    
    @Published
    var myName: String = ""
    @Published
    var myAddresses: [AddressName] = []
    
    @Published
    var globalBlocked: [AddressName] = []
    var localBlocked: [AddressName] {
        blockedAddresses
    }
    
    let interface: DataInterface
    
    var loaded: Bool = false
    var loading: Bool = false
    
    var error: Error?
    
    var requests: [AnyCancellable] = []
    
    init(client: ClientInfo, interface: DataInterface) {
        self.authenticationFetcher = AccountAuthDataFetcher(
            client: client,
            interface: interface
        )
        
        self.interface = interface
        
        subscribe()
        
        Task {
            await perform()
        }
    }
    
    @MainActor
    func subscribe() {
        authenticationFetcher.$authToken
            .sink { newValue in
                let newValue = newValue ?? ""
                guard !newValue.isEmpty else {
                    return
                }
                Task { [weak self] in
                    await self?.login(newValue)
                }
            }
            .store(in: &requests)
    }
    
    func perform() async {
        loading = true
        threadSafeSendUpdate()
        do {
            try await throwingRequest()
        } catch {
            handle(error)
        }
    }
    
    func login(_ incomingAuthKey: APICredential) async {
        authKey = incomingAuthKey
        await perform()
    }
    
    func logout() async {
        self.authKey = ""
        self.localAddresses = []
        await self.perform()
    }
    
    func throwingRequest() async throws {
        print("log fetching account")
        let blocked = try await interface.fetchPaste("app.lol.blocked", from: "app", credential: nil)?.content?.components(separatedBy: .newlines).map({ String($0) }).filter({ !$0.isEmpty }) ?? []
        self.globalBlocked = blocked
        guard !authKey.isEmpty else {
            threadSafeSendUpdate()
            return
        }
        let credential = authKey
        let addresses = try await interface.fetchAccountAddresses(credential)
        try await self.handleAddresses(addresses)
    }
    
    func fetchFinished() {
        loaded = true
        loading = false
        threadSafeSendUpdate()
    }
    
    func handle(_ incomingError: Error) {
        loaded = false
        loading = false
        error = incomingError
        threadSafeSendUpdate()
    }
    
    func handleAddresses(_ incomingAddresses: [AddressName]) async throws {
        let credential = authKey
        if let first = incomingAddresses.first, let name = try await interface.fetchAccountInfo(first, credential: credential)?.name {
            self.myName = name
        }
        myAddresses = incomingAddresses
        threadSafeSendUpdate()
    }
    
    func threadSafeSendUpdate() {
        objectWillChange.send()
    }
    
    var welcomeText: String {
        guard !myName.isEmpty else {
            return "Welcome"
        }
        return "Welcome, \(myName)"
    }
    
    var displayName: String {
        myName
    }
    
    var signedIn: Bool {
        !authKey.isEmpty
    }
    
    func authenticate() async {
        await logout()
        authenticationFetcher.perform()
    }
    
    public func credential(for address: AddressName) -> APICredential? {
        guard !authKey.isEmpty, myAddresses.contains(address) else {
            return nil
        }
        return authKey
    }
}
