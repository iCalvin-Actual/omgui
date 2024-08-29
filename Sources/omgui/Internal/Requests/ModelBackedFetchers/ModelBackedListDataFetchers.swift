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
    override var title: String {
        "omg.lol"
    }
    
    override func fetchRemote() async throws {
        guard results.isEmpty else {
            return
        }
        let directory = try await interface.fetchAddressDirectory()
        let listItems = directory.map({ AddressModel(name: $0) })
//        self.results = listItems
        listItems.forEach({ model in
            let db = db
            Task {
                try await model.write(to: db)
            }
        })
    }
}

class AccountAddressDataFetcher: ListDataFetcher<AddressModel> {
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
    
    override func throwingRequest() async throws {
        let credential = credential
        guard !credential.isEmpty else {
            results = []
            localAddressesCache = ""
            await fetchFinished()
            return
        }
        let results = try await interface.fetchAccountAddresses(credential).map({ AddressModel(name: $0) })
        
        self.results = results
        localAddressesCache = Array(Set(results.map({ $0.addressName }))).joined(separator: "&&&")
        await fetchFinished()
    }
    
    func clear() {
        myAddresses = []
    }
}

class AddressFollowingDataFetcher: ListDataFetcher<AddressModel> {
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
    
    override func throwingRequest() async throws {
        guard !address.isEmpty else {
            await fetchFinished()
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
            await self.fetchFinished()
            return
        }
        self.results = following.content.components(separatedBy: .newlines).map({ String($0) }).filter({ !$0.isEmpty }).map({ AddressModel(name: $0) })
    }
    
    private func handleItems(_ addresses: [AddressName]) async {
        self.results = addresses.map({ AddressModel(name: $0) })
        await self.fetchFinished()
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

class AddressBlockListDataFetcher: ListDataFetcher<AddressModel> {
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
            await fetchFinished()
            return
        }
        let address = address
        let credential = credential
        let pastes = try await interface.fetchAddressPastes(address, credential: credential)
        guard let blocked = pastes.first(where: { $0.name == "app.lol.blocked" }) else {
            await fetchFinished()
            return
        }
        self.results = blocked.content.components(separatedBy: .newlines).map({ String($0) }).filter({ !$0.isEmpty }).map({ AddressModel(name: $0) })
        await fetchFinished()
    }
    
    func block(_ toBlock: AddressName, credential: APICredential) async {
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
    
    override var title: String {
        "\(addressName.addressDisplayString).paste"
    }
    
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
    
    override var title: String {
        "\(addressName.addressDisplayString).PURLs"
    }
    
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
                return "status"
            case 1:
                return "@/statuses"
            default:
                return "statuses"
            }
        }()
        self.addresses = addresses
        super.init(addressBook: addressBook, interface: interface, db: db, filters: addresses.isEmpty ? [] : [.fromOneOf(addresses)])
    }
    
    override func fetchRemote() async throws {
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
    
    func fetchBacklog() async throws {
        let db = db
        let generalStatuses = try await self.interface.fetchCompleteStatusLog()
        generalStatuses.forEach({ model in
            Task { [model] in
                try await model.write(to: db)
            }
        })
        await self.fetchFinished()
    }
}
