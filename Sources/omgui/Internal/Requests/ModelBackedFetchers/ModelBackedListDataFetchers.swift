//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import Blackbird
import Foundation
import SwiftUI


class AddressDirectoryDataFetcher: ModelBackedListDataFetcher<AddressModel> {
    override var title: String { "omg.lol/" }
    
    override func fetchRemote() async throws {
        let directory = try await interface.fetchAddressDirectory()
        let listItems = directory.map({ AddressModel(name: $0) })
        listItems.forEach({ model in
            let db = db
            Task {
                try await model.write(to: db)
            }
        })
        guard results.isEmpty else {
            return
        }
    }
}

class AccountAddressDataFetcher: DataBackedListDataFetcher<AddressModel> {
    override var title: String {
        "my addresses"
    }
    private var credential: String
    
    @AppStorage("app.lol.cache.myAddresses")
    var localAddressesCache: String = ""
    var myAddresses: [AddressName] {
        get {
            let split = localAddressesCache.split(separator: "&&&")
            return split.map({ String($0) })
        }
        set {
            localAddressesCache = Array(Set(newValue)).joined(separator: "&&&")
        }
    }
    
    init(credential: APICredential, interface: DataInterface) {
        self.credential = credential
        super.init(interface: interface)
    }
    
    func configure(credential: APICredential, _ automation: AutomationPreferences = .init()) {
        self.credential = credential
        super.configure(automation)
    }
    
    @MainActor
    override func throwingRequest() async throws {
        
        let credential = credential
        guard !credential.isEmpty else {
            results = []
            localAddressesCache = ""
            return
        }
        let results = try await interface.fetchAccountAddresses(credential).map({ AddressModel(name: $0) })
        
        self.results = results
        localAddressesCache = Array(Set(results.map({ $0.addressName }))).joined(separator: "&&&")
    }
    
    func clear() {
        myAddresses = []
    }
}

class AddressFollowingDataFetcher: DataBackedListDataFetcher<AddressModel> {
    var address: AddressName
    var credential: APICredential?
    
    override var title: String {
        "following"
    }
    
    init(address: AddressName, credential: APICredential?, interface: DataInterface) {
        self.address = address
        self.credential = credential
        super.init(interface: interface)
    }
    
    func configure(address: AddressName, credential: APICredential?, _ automation: AutomationPreferences = .init()) {
        self.address = address
        self.credential = credential
        super.configure(automation)
    }
    
    @MainActor
    override func throwingRequest() async throws {
        
        guard !address.isEmpty else {
            return
        }
        let address = address
        let credential = credential
        let pastes = try await interface.fetchAddressPastes(address, credential: credential)
        
//        pastes.forEach({ model in
//            Task { @MainActor in
//                try await model.write(to: db)
//            }
//        })
        guard let following = pastes.first(where: { $0.name == "app.lol.following" }) else {
            return
        }
        self.results = following.content.components(separatedBy: .newlines).map({ String($0) }).filter({ !$0.isEmpty }).map({ AddressModel(name: $0) })
    }
    
    private func handleItems(_ addresses: [AddressName]) async {
        self.results = addresses.map({ AddressModel(name: $0) })
    }
    
    func follow(_ toFollow: AddressName, credential: APICredential) async {
        let newValue = Array(Set(self.results.map({ $0.addressName }) + [toFollow]))
        let newContent = newValue.joined(separator: "\n")
        let draft = PasteModel.Draft(
            address: address,
            name: "app.lol.following",
            content: newContent,
            listed: true
        )
        let address = address
        let credential = credential
        let _ = try? await interface.savePaste(draft, to: address, credential: credential)
        await handleItems(newValue)
    }
    
    func unFollow(_ toRemove: AddressName, credential: APICredential) async {
        let newValue = results.map({ $0.addressName }).filter({ $0 != toRemove })
        let newContent = newValue.joined(separator: "\n")
        let draft = PasteModel.Draft(
            address: address,
            name: "app.lol.following",
            content: newContent,
            listed: true
        )
        let address = address
        let credential = credential
        let _ = try? await interface.savePaste(draft, to: address, credential: credential)
        await handleItems(newValue)
    }
}

class AddressBlockListDataFetcher: DataBackedListDataFetcher<AddressModel> {
    var address: AddressName
    var credential: APICredential?
    
    override var title: String {
        "blocked from \(address)"
    }
    
    init(address: AddressName, credential: APICredential?, interface: DataInterface, automation: AutomationPreferences = .init()) {
        self.address = address
        self.credential = credential
        super.init(interface: interface)
    }
    
    func configure(address: AddressName, credential: APICredential?, _ automation: AutomationPreferences = .init()) {
        self.address = address
        self.credential = credential
        super.configure(automation)
    }
    
    override func throwingRequest() async throws {
        
        guard !address.isEmpty else {
            return
        }
        let address = address
        let credential = credential
        let pastes = try await interface.fetchAddressPastes(address, credential: credential)
        guard let blocked = pastes.first(where: { $0.name == "app.lol.blocked" }) else {
            return
        }
        self.results = blocked.content.components(separatedBy: .newlines).map({ String($0) }).filter({ !$0.isEmpty }).map({ AddressModel(name: $0) })
    }
    
    func block(_ toBlock: AddressName, credential: APICredential) async {
        loading = true
        let newValue = Array(Set(self.results.map({ $0.addressName }) + [toBlock]))
        let newContent = newValue.joined(separator: "\n")
        let draft = PasteModel.Draft(
            address: address,
            name: "app.lol.blocked",
            content: newContent,
            listed: false
        )
        let address = address
        let credential = credential
        let _ = try? await self.interface.savePaste(draft, to: address, credential: credential)
        await self.handleItems(newValue)
        
    }
    
    func unBlock(_ toUnblock: AddressName, credential: APICredential) async {
        loading = true
        let newValue = results.map({ $0.addressName }).filter({ $0 != toUnblock })
        let newContent = newValue.joined(separator: "\n")
        let draft = PasteModel.Draft(
            address: address,
            name: "app.lol.blocked",
            content: newContent,
            listed: false
        )
        let address = address
        let credential = credential
        let _ = try? await interface.savePaste(draft, to: address, credential: credential)
        await self.handleItems(newValue)
    }
    
    private func handleItems(_ addresses: [AddressName]) async {
        self.results = addresses.map({ AddressModel(name: $0) })
        loaded = .init()
        await fetchFinished()
    }
}

class NowGardenDataFetcher: ModelBackedListDataFetcher<NowListing> {
    override var title: String {
        "now.garden🌷"
    }
    
    override func fetchRemote() async throws {
        let garden = try await interface.fetchNowGarden()
        garden.forEach { model in
            Task { [db] in
                try await model.write(to: db)
            }
        }
    }
}

class AddressPasteBinDataFetcher: ModelBackedListDataFetcher<PasteModel> {
    let addressName: AddressName
    let credential: APICredential?
    
    init(name: AddressName, pastes: [PasteModel] = [], credential: APICredential?, addressBook: AddressBook, interface: DataInterface, db: Blackbird.Database) {
        self.addressName = name
        self.credential = credential
        super.init(addressBook: addressBook, interface: interface, db: db, filters: [.from(name)])
    }
    
    override func fetchRemote() async throws {
        guard !addressName.isEmpty else {
            return
        }
        let pastes = try await interface.fetchAddressPastes(addressName, credential: credential)
        let db = db
        pastes.forEach({ model in
            Task {
                try await model.write(to: db)
            }
        })
    }
}

class AddressPURLsDataFetcher: ModelBackedListDataFetcher<PURLModel> {
    let addressName: AddressName
    let credential: APICredential?
    
    init(name: AddressName, purls: [PURLModel] = [], credential: APICredential?, addressBook: AddressBook, interface: DataInterface, db: Blackbird.Database) {
        self.addressName = name
        self.credential = credential
        super.init(addressBook: addressBook, interface: interface, db: db, filters: [.from(name)])
    }
    
    override func fetchRemote() async throws {
        guard !addressName.isEmpty else {
            return
        }
        let purls = try await interface.fetchAddressPURLs(addressName, credential: credential)
        let db = db
        purls.forEach({ model in
            Task {
                try await model.write(to: db)
            }
        })
    }
}

class StatusLogDataFetcher: ModelBackedListDataFetcher<StatusModel> {
    let displayTitle: String
    let addresses: [AddressName]
    
    override var title: String { displayTitle }
    
    init(title: String? = nil, addresses: [AddressName] = [], addressBook: AddressBook, interface: DataInterface, db: Blackbird.Database) {
        self.displayTitle = title ?? {
            switch addresses.count {
            case 0:
                return "status.lol/"
            case 1:
                return ""
            default:
                return "statuses"
            }
        }()
        self.addresses = addresses
        super.init(addressBook: addressBook, interface: interface, db: db, filters: addresses.isEmpty ? [] : [.fromOneOf(addresses)])
    }
    
    override func fetchRemote() async throws {
        defer {
            nextPage = 0
        }
        try await super.fetchRemote()
        let db = db
        if addresses.isEmpty {
            let statuses = try await interface.fetchStatusLog()
            statuses.forEach({ model in
                Task {
                    try await model.write(to: db)
                }
            })
        } else {
            let statuses = try await interface.fetchAddressStatuses(addresses: addresses)
            statuses.forEach({ model in
                Task { [model] in
                    try await model.write(to: db)
                }
            })
        }
    }
    
    @MainActor
    func fetchBacklog() async throws {
        let db = db
        let generalStatuses = try await self.interface.fetchCompleteStatusLog()
        generalStatuses.forEach({ model in
            Task { [model] in
                try await model.write(to: db)
            }
        })
        self.loading = true
        self.loaded = .init()
        self.loading = false
    }
}
