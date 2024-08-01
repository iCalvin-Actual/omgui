//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import Blackbird
import Foundation


class AddressDirectoryDataFetcher: ModelBackedListDataFetcher<AddressModel> {
    override var title: String {
        "omg.lol"
    }
    
    override func fetchModels() async throws {
        self.results = try await AddressModel.read(from: db, orderBy: .ascending(\.$id))
    }
    
    override func fetchRemote() async throws {
        guard results.isEmpty else {
            return
        }
        let directory = try await interface.fetchAddressDirectory()
        let listItems = directory.map({ AddressModel(name: $0) })
        
        listItems.forEach({ model in
            Task {
                try await model.write(to: db)
            }
        })
    }
}

class AccountAddressDataFetcher: ModelBackedListDataFetcher<AddressModel> {
    override var title: String {
        "my addresses"
    }
    private let credential: String
    
    init(credential: APICredential, interface: DataInterface, db: Blackbird.Database) {
        self.credential = credential
        super.init(interface: interface, db: db)
    }
    
    override func fetchRemote() async throws {
        self.results = try await interface.fetchAccountAddresses(credential).map({ AddressModel(name: $0) })
        
        self.results.forEach({ model in
            Task {
                try await model.write(to: db)
            }
        })
    }
}

class AddressFollowingDataFetcher: ModelBackedListDataFetcher<AddressModel> {
    let address: AddressName
    let credential: APICredential?
    
    override var title: String {
        "following"
    }
    
    init(address: AddressName, credential: APICredential?, interface: DataInterface, db: Blackbird.Database) {
        self.address = address
        self.credential = credential
        super.init(interface: interface, db: db)
    }
    
    override func throwingRequest() async throws {
        guard !address.isEmpty else {
            fetchFinished()
            return
        }
        let pastes = try await interface.fetchAddressPastes(address, credential: credential)
        
        pastes.forEach({ model in
            Task {
                try await model.write(to: db)
            }
        })
        guard let following = pastes.first(where: { $0.name == "app.lol.following" }) else {
            self.fetchFinished()
            return
        }
        self.results = following.content.components(separatedBy: .newlines).map({ String($0) }).filter({ !$0.isEmpty }).map({ AddressModel(name: $0) })
    }
    
    private func handleItems(_ addresses: [AddressName]) {
        let paste = PasteModel(
            owner: address,
            name: "app.lol.following",
            content: addresses.joined(separator: "\n"),
            listed: true
        )
        self.results = addresses.map({ AddressModel(name: $0) })
        Task {
            try await paste.write(to: db)
        }
        self.fetchFinished()
        self.threadSafeSendUpdate()
    }
    
    func follow(_ toFollow: AddressName, credential: APICredential) {
        let newValue = Array(Set(self.results.map({ $0.addressName }) + [toFollow]))
        let newContent = newValue.joined(separator: "\n")
        let draft = PasteModel.Draft(
            address: address,
            name: "app.lol.following",
            content: newContent,
            listed: true
        )
        Task {
            let _ = try await self.interface.savePaste(draft, to: address, credential: credential)
            self.handleItems(newValue)
        }
    }
    
    func unFollow(_ toRemove: AddressName, credential: APICredential) {
        let newValue = results.map({ $0.addressName }).filter({ $0 != toRemove })
        let newContent = newValue.joined(separator: "\n")
        let draft = PasteModel.Draft(
            address: address,
            name: "app.lol.following",
            content: newContent,
            listed: true
        )
        Task {
            let _ = try await self.interface.savePaste(draft, to: address, credential: credential)
            self.handleItems(newValue)
        }
    }
}

class AddressBlockListDataFetcher: ModelBackedListDataFetcher<AddressModel> {
    let address: AddressName
    let credential: APICredential?
    
    override var title: String {
        "blocked from \(address)"
    }
    
    init(address: AddressName, credential: APICredential?, interface: DataInterface, db: Blackbird.Database) {
        self.address = address
        self.credential = credential
        super.init(interface: interface, db: db)
    }
    
    override func throwingRequest() async throws {
        defer {
            fetchFinished()
        }
        guard !address.isEmpty else {
            return
        }
        let pastes = try await interface.fetchAddressPastes(address, credential: credential)
        pastes.forEach({ model in
            Task {
                try await model.write(to: db)
            }
        })
        guard let blocked = pastes.first(where: { $0.name == "app.lol.blocked" }) else {
            return
        }
        self.results = blocked.content.components(separatedBy: .newlines).map({ String($0) }).filter({ !$0.isEmpty }).map({ AddressModel(name: $0) })
    }
    
    func block(_ toBlock: AddressName, credential: APICredential) {
        let newValue = Array(Set(self.results.map({ $0.addressName }) + [toBlock]))
        let newContent = newValue.joined(separator: "\n")
        let draft = PasteModel.Draft(
            address: address,
            name: "app.lol.blocked",
            content: newContent,
            listed: false
        )
        Task {
            let _ = try await self.interface.savePaste(draft, to: address, credential: credential)
            self.handleItems(newValue)
        }
        
    }
    
    func unBlock(_ toUnblock: AddressName, credential: APICredential) {
        let newValue = results.map({ $0.addressName }).filter({ $0 != toUnblock })
        let newContent = newValue.joined(separator: "\n")
        let draft = PasteModel.Draft(
            address: address,
            name: "app.lol.blocked",
            content: newContent,
            listed: false
        )
        Task {
            let _ = try await self.interface.savePaste(draft, to: address, credential: credential)
            self.handleItems(newValue)
        }
    }
    
    private func handleItems(_ addresses: [AddressName]) {
        let paste = PasteModel(
            owner: address,
            name: "app.lol.blocked",
            content: addresses.joined(separator: "\n"),
            listed: true
        )
        self.results = addresses.map({ AddressModel(name: $0) })
        Task {
            try await paste.write(to: db)
        }
        self.fetchFinished()
        self.threadSafeSendUpdate()
    }
}

class NowGardenDataFetcher: ModelBackedListDataFetcher<NowListing> {
    override var title: String {
        "now.garden🌷"
    }
    override func fetchModels() async throws {
        results = try await NowListing.read(from: db, orderBy: .ascending(\.$id))
    }
    override func fetchRemote() async throws {
        let garden = try await interface.fetchNowGarden()
        garden.forEach { model in
            Task {
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
    
    init(name: AddressName, pastes: [PasteModel] = [], interface: DataInterface, credential: APICredential?, db: Blackbird.Database) {
        self.addressName = name
        self.credential = credential
        super.init(interface: interface, db: db)
    }
    
    override func fetchModels() async throws {
        self.results = try await PasteModel.read(from: db, matching: \.$owner == addressName)
    }
    
    override func fetchRemote() async throws {
        guard !addressName.isEmpty else {
            return
        }
        let pastes = try await interface.fetchAddressPastes(addressName, credential: credential)
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
    
    init(name: AddressName, purls: [PURLModel] = [], interface: DataInterface, credential: APICredential?, db: Blackbird.Database) {
        self.addressName = name
        self.credential = credential
        super.init(interface: interface, db: db)
    }
    
    override func fetchModels() async throws {
        self.results = try await PURLModel.read(from: db, matching: \.$owner == addressName)
    }
    
    override func fetchRemote() async throws {
        guard !addressName.isEmpty else {
            return
        }
        let purls = try await interface.fetchAddressPURLs(addressName, credential: credential)
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
    
    init(title: String? = nil, addresses: [AddressName] = [], interface: DataInterface, db: Blackbird.Database) {
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
        super.init(interface: interface, db: db)
    }
    
    override func fetchModels() async throws {
        if addresses.isEmpty {
            let results = try await StatusModel.read(from: db, orderBy: .descending(\.$posted))
            self.results = results
        } else {
            let results = try await StatusModel.read(from: db, matching: .valueIn(\.$address, addresses), orderBy: .descending(\.$posted))
            self.results = results
        }
    }
    
    override func fetchRemote() async throws {
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
                Task {
                    try await model.write(to: db)
                }
            })
        }
    }
}
