//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Combine
import Foundation
import SwiftUI

public class AppModel: ObservableObject {
    
    // MARK: - Definitions
    
    let client: ClientInfo
    let interface: DataInterface
    
    // MARK: Authentication
    let accountModel: AccountModel = .init()
    
    @AppStorage("app.lol.auth", store: .standard)
    private var authKey: String = ""
    
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
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    
    // MARK: Pinning
    @AppStorage("app.lol.cache.pinned.history", store: .standard)
    private var pinnedAddressesHistory: String = "app"
    var previouslyPinnedAddresses: Set<AddressName> {
        get {
            let split = pinnedAddressesHistory.split(separator: "&&&")
            return Set(split.map({ String($0) }))
        }
        set {
            pinnedAddressesHistory = newValue.sorted().joined(separator: "&&&")
        }
    }
    
    @AppStorage("app.lol.cache.pinned", store: .standard)
    private var currentlyPinnedAddresses: String = "app"
    var pinnedAddresses: [AddressName] {
        get {
            let split = currentlyPinnedAddresses.split(separator: "&&&")
            return split.map({ String($0) })
        }
        set {
            currentlyPinnedAddresses = Array(Set(newValue)).joined(separator: "&&&")
            newValue.forEach({ previouslyPinnedAddresses.insert($0) })
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    
    // MARK: Fetching
    
    internal var fetchConstructor: FetchConstructor
    private var authFetcher: AccountAuthDataFetcher
    private var profileModels: [AddressName: AddressSummaryDataFetcher] = [:]
    
    private var requests: [AnyCancellable] = []
    
    public init(client: ClientInfo, dataInterface: DataInterface) {
        self.client = client
        self.interface = dataInterface
        self.fetchConstructor = FetchConstructor(client: client, interface: dataInterface)
        self.authFetcher = fetchConstructor.credentialFetcher()
        
        
        
        // MARK: Subscribers
        
        authFetcher.$authToken.sink { [self] newValue in
            let newValue = newValue ?? ""
            if !authKey.isEmpty && newValue.isEmpty {
                self.logout()
            }
            guard !newValue.isEmpty else {
                // Clear anything?
                return
            }
            Task {
                await self.login(newValue)
            }
        }
        .store(in: &requests)
    }
    
    private func fetch() {
        Task {
            for address in (pinnedAddresses + accountModel.addresses.map({ $0.addressName })) {
                let _ = addressDetails(address)
            }
        }
    }
    
    func addressDetails(_ address: AddressName) -> AddressSummaryDataFetcher {
        if let model = profileModels[address] {
            Task {
                await model.update()
            }
            return model
        } else {
            let newModel = fetchConstructor.addressDetailsFetcher(address)
            profileModels[address] = newModel
            return newModel
        }
    }
    
    // MARK: - Functions
    
    // MARK: Authentication
    
    func authenticate() {
        if !self.authKey.isEmpty {
            self.authKey = ""
        }
        
        Task {
            await authFetcher.update()
        }
    }
    
    func login(_ authKey: String) async {
        self.authKey = authKey
        let fetcher = fetchConstructor.accountAddressesDataFetcher(authKey)
        
        fetcher.$listItems.sink { addresses in
            addresses.forEach { model in
                let _ = self.addressDetails(model.name)
            }
            
            let notPreviouslyPinned = addresses.map({ $0.name }).filter({ !self.previouslyPinnedAddresses.contains($0) })
            self.pinnedAddresses.append(contentsOf: notPreviouslyPinned)
        }
        .store(in: &requests)
        
        await fetcher.update()
        // Add addresses to pinned list
        // Fetch app.lol settings for addresses
    }
    
    func logout() {
        self.authKey = ""
    }
    
    // MARK: Local List Managment
    
    func isPinned(_ address: AddressName) -> Bool {
        pinnedAddresses.contains(address)
    }
    
    func pin(_ address: AddressName) {
        self.pinnedAddresses.append(address)
    }
    
    func removePin(_ address: AddressName) {
        self.pinnedAddresses.removeAll(where: { $0 == address })
    }
    
    var directory: [AddressModel] {
        fetchConstructor.directory
    }
}
