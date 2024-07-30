//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import Blackbird
import Foundation


class AddressProfileDataFetcher: ModelBackedDataFetcher<AddressProfile> {
    
    let addressName: AddressName
    let credential: APICredential?
    
    init(name: AddressName, credential: APICredential? = nil, interface: DataInterface, db: Blackbird.Database) {
        self.addressName = name
        self.credential = credential
        super.init(interface: interface, db: db)
    }
    
    override func fetchModels() async throws {
        result = try await AddressProfile.read(from: db, id: addressName)
    }
    
    override func fetchRemote() async throws {
        guard !addressName.isEmpty, result == nil else {
            return
        }
        let profile = try await interface.fetchAddressProfile(addressName, credential: credential)
        try await profile?.write(to: db)
    }
}

@MainActor
class AddressNowDataFetcher: ModelBackedDataFetcher<NowModel> {
    let addressName: AddressName
    
    init(name: AddressName, interface: DataInterface, db: Blackbird.Database) {
        self.addressName = name
        super.init(interface: interface, db: db)
    }
    
    override func fetchModels() async throws {
        self.result = try await NowModel.read(from: db, id: addressName)
    }
    
    override func fetchRemote() async throws {
        guard !addressName.isEmpty, result == nil else {
            return
        }
        let now = try await interface.fetchAddressNow(addressName)
        try await now?.write(to: db)
    }
}

class StatusDataFetcher: ModelBackedDataFetcher<StatusModel> {
    let address: AddressName
    let id: String
    
    var linkFetchers: [URLContentDataFetcher] {
        guard let links = result?.webLinks else {
            return []
        }
        return links.map({
            .init(url: $0.content, interface: interface)
        })
    }
    
    init(id: String, from address: String, interface: DataInterface, db: Blackbird.Database) {
        self.address = address
        self.id = id
        super.init(interface: interface, db: db)
    }
    
    override func fetchModels() async throws {
        result = try await StatusModel.read(from: db, id: id)
    }
    
    override func fetchRemote() async throws {
        try await interface.fetchAddressStatus(id, from: address)?.write(to: db)
    }
    
    func fetcher(for url: URL) -> URLContentDataFetcher? {
        linkFetchers.first(where: { $0.url == url })
    }
}
