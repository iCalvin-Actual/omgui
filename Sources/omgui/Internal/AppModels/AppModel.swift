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
    var accountModel: AccountModel
    
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
    private var profileModels: [AddressName: AddressSummaryDataFetcher] = [:]
    
    private var requests: [AnyCancellable] = []
    
    public init(client: ClientInfo, dataInterface: DataInterface) {
        self.client = client
        self.interface = dataInterface
        self.fetchConstructor = FetchConstructor(client: client, interface: dataInterface)
        self.accountModel = .init(fetchConstructor: fetchConstructor)
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
