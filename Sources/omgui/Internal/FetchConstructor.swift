//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import SwiftData
import SwiftUI
import Foundation

actor FetchConstructor {
    @AppStorage("app.lol.auth", store: .standard)
    var authKey: String = ""
    
    let client: ClientInfo
    let interface: DataInterface
    let context: ModelContext
    
    init(client: ClientInfo, interface: DataInterface, container: ModelContainer) {
        self.client = client
        self.interface = interface
        self.context = .init(container)
    }
    
    func credential(for address: AddressName) -> String? {
        authKey
    }
    
    func fetchBio(_ address: AddressName) async throws {
        print("LOG: Fetching bio: \(address)")
        let bioResponse: AddressBioResponse = try await interface.fetchAddressBio(address)
        let model = AddressBioModel(bioResponse)
        context.insert(model)
    }
    
    func fetchStatusLog() async throws {
        print("LOG: fetching statusLog")
        let addressResponses = try await interface.fetchStatusLog()
        let models = addressResponses.map { StatusModel($0) }
        models.forEach{( context.insert($0) )}
        try? context.save()
    }
    
    func fetchStatuses(_ addresses: [AddressName]) async throws {
        print("LOG: fetchBatchStatuses \(addresses)")
        let addressResponses = try await interface.fetchAddressStatuses(addresses: addresses)
        let models = addressResponses.map { StatusModel($0) }
        models.forEach{( context.insert($0) )}
        try? context.save()
    }
    
    func fetchProfile(_ address: AddressName) async throws {
        print("LOG: ")
        if let profileResponse: AddressProfile = try await interface.fetchAddressProfile(address, credential: nil) {
            let model: AddressProfileModel = .init(profileResponse)
            context.insert(model)
        }
    }
    
    func fetchProfileContent(_ address: AddressName) async throws {
        print("LOG: fetching profile \(address)")
        let credential = credential(for: address)
        
        if let profileResponse: AddressProfile = try await interface.fetchAddressProfile(address, credential: credential) {
            let model: AddressProfileModel = .init(profileResponse)
            context.insert(model)
        }
    }
    
    func fetchNow(_ address: AddressName) async throws {
        print("LOG: ")
        let predicate = #Predicate<AddressNowListingModel> {
            $0.owner == address
        }
        let fetchDescriptor = FetchDescriptor<AddressNowListingModel>(predicate: predicate)
        let result = try context.fetch(fetchDescriptor).first
        if let nowResponse: NowModel = try await interface.fetchAddressNow(address) {
            let url = result?.url ?? "https://\(address).omg.lol/now"
            let model: AddressNowModel = .init(nowResponse, url: url)
            context.insert(model)
        }
    }
    
    func fetchNowGarden() async throws {
        print("LOG: fetching now garden")
        let listings = try await interface.fetchNowGarden()
        let models = listings.map({ AddressNowListingModel($0) })
        models.forEach{( context.insert($0) )}
    }
        
    func fetchPURLS(_ address: AddressName) async throws {
        print("LOG: ")
        try await fetchPURLS([address])
    }
    
    func fetchPURLS(_ addresses: [AddressName]) async throws {
        print("LOG: fetching batch purls \(addresses)")
        for address in addresses {
            let credential = credential(for: address)
            async let purlsResponse = try interface.fetchAddressPURLs(address, credential: credential)
            let models = try await purlsResponse.map({ AddressPURLModel($0) })
            insertModels(models: models, autoSave: true)
            try? context.save()
        }
    }
    
    func fetchPURL(_ address: AddressName, title: String) async throws {
        print("LOG: ")
        let credential = credential(for: address)
        
        if let purlResponse = try await interface.fetchPURL(title, from: address, credential: credential) {
            let model = AddressPURLModel(purlResponse)
            insertModels(models: [model], autoSave: true)
            try? context.save()
        }
    }
    
    func fetchPastes(_ address: AddressName) async throws {
        print("LOG: fetching address Pastes \(address)")
        try await fetchPastes([address])
    }
    
    func fetchPastes(_ addresses: [AddressName]) async throws {
        print("LOG: fetching batch pastes \(addresses)")
        for address in addresses {
            let credential = credential(for: address)
            async let pastesResponse = try interface.fetchAddressPastes(address, credential: credential)
            let models = try await pastesResponse.map({ AddressPasteModel($0) })
            models.forEach{( context.insert($0) )}
        }
    }
    
    func fetchPaste(_ address: AddressName, title: String) async throws {
        print("LOG: fetching paste \(address)/\(title)")
        let credential = credential(for: address)
        
        if let purlResponse = try await interface.fetchPaste(title, from: address, credential: credential) {
            let model = AddressPasteModel(purlResponse)
            context.insert(model)
        }
    }
    
    func fetchInfo(_ address: AddressName) async throws {
        print("LOG: fetching info \(address)")
        fetchIcon(address)
        guard !address.isEmpty else {
            return
        }
        let info = try await interface.fetchAddressInfo(address)
        if let url = info.url {
            async let following = fetchFollowing(address)
            async let blocked = fetchBlocked(address)
            let infoModel = AddressInfoModel(owner: address, url: url, registered: info.registered ?? Date(), following: try await following, blocked: try await blocked)
            context.insert(infoModel)
        }
    }
    
    func fetchIcon(_ address: AddressName) {
        print("LOG: fetching icon (but not really) \(address)")
//        Task { [weak self] in
//            guard let self, !address.isEmpty, let url = address.addressIconURL else {
//                return
//            }
//            let request = URLRequest(url: url)
//            let (data, _) = try await URLSession.shared.data(for: request)
//            let iconModel = AddressIconModel(owner: address, imageData: data)
//            insertModels(models: [iconModel])
//        }
    }
    
    func fetchBlocked(_ address: AddressName = "app") async throws -> [AddressName] {
        print("LOG: fetching blocked \(address)")
        let title = "app.lol.blocked"
        try await fetchPastes(address)
        let predicate = #Predicate<AddressPasteModel> {
            $0.id == "\(address)/\(title)"
        }
        let fetchDescriptor = FetchDescriptor<AddressPasteModel>(predicate: predicate)
        let result = try context.fetch(fetchDescriptor).first
        let list = result?.content?.components(separatedBy: .newlines).map({ String($0) }).filter({ !$0.isEmpty }) ?? []
        return list
    }
    
    func saveBlocked(_ addresses: [AddressName], for address: AddressName) async throws {
        print("LOG: updating blocked \(address): \(addresses)")
        guard let credential = credential(for: address) else {
            return
        }
        let title = "app.lol.blocked"
        let draft: PasteResponse.Draft = .init(address: address, name: title, content: addresses.joined(separator: "\n"))
        let _ = try await interface.savePaste(draft, to: address, credential: credential)
        let _ = try await fetchFollowing(address)
    }
    
    func fetchFollowing(_ address: AddressName) async throws -> [AddressName] {
        print("LOG: fetching blocked \(address)")
        let title = "app.lol.following"
        try await fetchPastes(address)
        
        let predicate = #Predicate<AddressPasteModel> {
            $0.id == "\(address)/\(title)"
        }
        let fetchDescriptor = FetchDescriptor<AddressPasteModel>(predicate: predicate)
        let result = try context.fetch(fetchDescriptor).first
        let list = result?.content?.components(separatedBy: .newlines).map({ String($0) }).filter({ !$0.isEmpty }) ?? []
        return list
    }
    
    func saveFollowing(_ addresses: [AddressName], for address: AddressName) async throws {
        print("LOG: updating blocked \(address): \(addresses)")
        guard let credential = credential(for: address) else {
            return
        }
        let title = "app.lol.following"
        let draft: PasteResponse.Draft = .init(address: address, name: title, content: addresses.joined(separator: "\n"))
        let _ = try await interface.savePaste(draft, to: address, credential: credential)
        let _ = try await fetchFollowing(address)
    }
    
    func fetchDirectory() async throws {
        print("LOG: fetching directory")
        let addresses = try await interface.fetchAddressDirectory()
        let models = addresses.map({ AddressNameModel(name: $0) })
        models.forEach{( context.insert($0) )}
        try? context.save()
    }
    
    func insertModels(models: [any PersistentModel], autoSave: Bool = false) {
        print("LOG: insert models \(models.count)")
        models.forEach{( context.insert($0) )}
        if autoSave {
            print("LOG: manually saving")
            try? context.save()
        }
    }
}
