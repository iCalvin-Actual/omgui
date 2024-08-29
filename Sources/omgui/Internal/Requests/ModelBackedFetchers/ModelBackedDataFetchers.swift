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
    
    @MainActor
    override func fetchModels() async throws {
        self.result = try await AddressProfile.read(from: db, id: addressName)
    }
    
    override func fetchRemote() async throws {
        guard !addressName.isEmpty, result == nil else {
            return
        }
        let profile = try await interface.fetchAddressProfile(addressName, credential: credential)
        try await profile?.write(to: db)
    }
}

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
        let status = try await interface.fetchAddressStatus(id, from: address)
        try await status?.write(to: db)
    }
    
    func fetcher(for url: URL) -> URLContentDataFetcher? {
        linkFetchers.first(where: { $0.url == url })
    }
}

class AddressPasteDataFetcher: ModelBackedDataFetcher<PasteModel> {
    let address: AddressName
    let title: String
    let credential: APICredential?
    
    init(name: AddressName, title: String, credential: APICredential? = nil, interface: any DataInterface, db: Blackbird.Database) {
        self.address = name
        self.title = title
        self.credential = credential
        super.init(interface: interface, db: db)
    }
    
//    var draftPoster: PasteDraftPoster? {
//        guard let credential else {
//            return super.draftPoster as? PasteDraftPoster
//        }
//        if let model {
//            return .init(
//                addressName,
//                title: model.name,
//                content: model.content ?? "",
//                interface: interface,
//                credential: credential
//            )
//        } else {
//            return .init(
//                addressName,
//                title: "",
//                interface: interface,
//                credential: credential
//            )
//        }
//    }
    
    override func fetchModels() async throws {
        self.result = try await PasteModel.read(from: db, id: title)
    }
    
    override func fetchRemote() async throws {
        guard !address.isEmpty, !title.isEmpty else {
            return
        }
        let paste = try await interface.fetchPaste(title, from: address, credential: credential)
        try await paste?.write(to: db)
    }
    
    func deleteIfPossible() async throws {
        guard let credential else {
            return
        }
        let _ = try await interface.deletePaste(title, from: address, credential: credential)
        try await result?.delete(from: db)
        await fetchFinished()
    }
}

class AddressPURLDataFetcher: ModelBackedDataFetcher<PURLModel> {
    let address: AddressName
    let title: String
    let credential: APICredential?
    
    init(name: AddressName, title: String, credential: APICredential? = nil, interface: any DataInterface, db: Blackbird.Database) {
        self.address = name
        self.title = title
        self.credential = credential
        super.init(interface: interface, db: db)
    }
    
//    var draftPoster: PURLDraftPoster? {
//        guard let credential else {
//            return super.draftPoster as? PasteDraftPoster
//        }
//        if let model {
//            return .init(
//                addressName,
//                title: model.name,
//                content: model.content ?? "",
//                interface: interface,
//                credential: credential
//            )
//        } else {
//            return .init(
//                addressName,
//                title: "",
//                interface: interface,
//                credential: credential
//            )
//        }
//    }
    
    override func fetchModels() async throws {
        self.result = try await PURLModel.read(from: db, id: title)
    }
    
    override func fetchRemote() async throws {
        guard !address.isEmpty, !title.isEmpty else {
            return
        }
        let purl = try await interface.fetchPURL(title, from: address, credential: credential)
        try await purl?.write(to: db)
    }
    
    func deleteIfPossible() async throws {
        guard let credential else {
            return
        }
        let _ = try await interface.deletePURL(title, from: address, credential: credential)
        try await result?.delete(from: db)
        result = nil
        await fetchFinished()
    }
}
