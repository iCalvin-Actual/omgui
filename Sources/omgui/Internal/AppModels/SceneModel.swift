//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/6/23.
//

import Combine
import SwiftData
import SwiftUI

@Observable
@MainActor
class SceneModel {
    
    let fetchConstructor: FetchConstructor
    var accountModel: AccountModel
    let actingAddress: AddressName
    
    var requests: [AnyCancellable] = []
    
    var context: ModelContext
    
    var editingModel: Editable?
    
    var destinationConstructor: DestinationConstructor {
        .init(
            accountModel: accountModel,
            fetchConstructor: fetchConstructor
        )
    }
    
    init(actingAddress: AddressName, fetchConstructor: FetchConstructor, context: ModelContext) {
        self.fetchConstructor = fetchConstructor
        self.actingAddress = actingAddress
        self.accountModel = fetchConstructor.constructAccountModel()
        self.context = context
    }
    
    func fetchBio(_ address: AddressName) async throws {
        print("LOG: Fetching bio: \(address)")
        let bioResponse: AddressBioResponse = try await fetchConstructor.interface.fetchAddressBio(address)
        let model = AddressBioModel(bioResponse)
        insertModels([model])
    }
    
    func fetchStatusLog() async throws {
        print("LOG: fetching statusLog")
        let addressResponses = try await fetchConstructor.interface.fetchStatusLog()
        let models = addressResponses.map { StatusModel($0) }
        insertProblematicModels(models)
    }
    
    func fetchStatuses(_ addresses: [AddressName]) async throws {
        print("LOG: fetchBatchStatuses \(addresses)")
        let addressResponses = try await fetchConstructor.interface.fetchAddressStatuses(addresses: addresses)
        let models = addressResponses.map { StatusModel($0) }
        insertProblematicModels(models)
    }
    
    func fetchProfile(_ address: AddressName) async throws {
        print("LOG: ")
        if let profileResponse: AddressProfile = try await fetchConstructor.interface.fetchAddressProfile(address, credential: nil) {
            let model: AddressProfileModel = .init(profileResponse)
            insertModels([model])
        }
    }
    
    func fetchProfileContent(_ address: AddressName) async throws {
        print("LOG: fetching profile \(address)")
        let credential = accountModel.credential(for: address)
        
        if let profileResponse: AddressProfile = try await fetchConstructor.interface.fetchAddressProfile(address, credential: credential) {
            let model: AddressProfileModel = .init(profileResponse)
            insertModels([model])
        }
    }
    
    func fetchNow(_ address: AddressName) async throws {
        print("LOG: ")
        let predicate = #Predicate<AddressNowListingModel> {
            $0.owner == address
        }
        let fetchDescriptor = FetchDescriptor<AddressNowListingModel>(predicate: predicate)
        let result = try context.fetch(fetchDescriptor).first
        if let nowResponse: NowModel = try await fetchConstructor.interface.fetchAddressNow(address) {
            let url = result?.url ?? "https://\(address).omg.lol/now"
            let model: AddressNowModel = .init(nowResponse, url: url)
            insertModels([model])
        }
    }
    
    func fetchNowGarden() async throws {
        print("LOG: fetching now garden")
        let listings = try await fetchConstructor.interface.fetchNowGarden()
        let models = listings.map({ AddressNowListingModel($0) })
        insertModels(models)
    }
        
    func fetchPURLS(_ address: AddressName) async throws {
        print("LOG: ")
        try await fetchPURLS([address])
    }
    
    func fetchPURLS(_ addresses: [AddressName]) async throws {
        print("LOG: fetching batch purls \(addresses)")
        for address in addresses {
            let credential = accountModel.credential(for: address)
            async let purlsResponse = try fetchConstructor.interface.fetchAddressPURLs(address, credential: credential)
            let models = try await purlsResponse.map({ AddressPURLModel($0) })
            insertProblematicModels(models)
        }
    }
    
    func fetchPURL(_ address: AddressName, title: String) async throws {
        print("LOG: ")
        let credential = accountModel.credential(for: address)
        
        if let purlResponse = try await fetchConstructor.interface.fetchPURL(title, from: address, credential: credential) {
            let model = AddressPURLModel(purlResponse)
            insertProblematicModels([model])
        }
    }
    
    func fetchPastes(_ address: AddressName) async throws {
        print("LOG: fetching address Pastes \(address)")
        try await fetchPastes([address])
    }
    
    func fetchPastes(_ addresses: [AddressName]) async throws {
        print("LOG: fetching batch pastes \(addresses)")
        for address in addresses {
            let credential = accountModel.credential(for: address)
            async let pastesResponse = try fetchConstructor.interface.fetchAddressPastes(address, credential: credential)
            let models = try await pastesResponse.map({ AddressPasteModel($0) })
            insertModels(models)
        }
    }
    
    func fetchPaste(_ address: AddressName, title: String) async throws {
        print("LOG: fetching paste \(address)/\(title)")
        let credential = accountModel.credential(for: address)
        
        if let purlResponse = try await fetchConstructor.interface.fetchPaste(title, from: address, credential: credential) {
            let model = AddressPasteModel(purlResponse)
            insertModels([model])
        }
    }
    
    func fetchInfo(_ address: AddressName) async throws {
        print("LOG: fetching info \(address)")
        fetchIcon(address)
        guard !address.isEmpty else {
            return
        }
        let info = try await fetchConstructor.interface.fetchAddressInfo(address)
        if let url = info.url {
            async let following = fetchFollowing(address)
            async let blocked = fetchBlocked(address)
            let infoModel = AddressInfoModel(owner: address, url: url, registered: info.registered ?? Date(), following: try await following, blocked: try await blocked)
            insertModels([infoModel])
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
//            insertModels([iconModel])
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
        guard let credential = accountModel.credential(for: address) else {
            return
        }
        let title = "app.lol.blocked"
        let draft: PasteResponse.Draft = .init(address: address, name: title, content: addresses.joined(separator: "\n"))
        let _ = try await fetchConstructor.interface.savePaste(draft, to: address, credential: credential)
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
        guard let credential = accountModel.credential(for: address) else {
            return
        }
        let title = "app.lol.following"
        let draft: PasteResponse.Draft = .init(address: address, name: title, content: addresses.joined(separator: "\n"))
        let _ = try await fetchConstructor.interface.savePaste(draft, to: address, credential: credential)
        let _ = try await fetchFollowing(address)
    }
    
    func fetchDirectory() async throws {
        print("LOG: fetching directory")
        let addresses = try await fetchConstructor.interface.fetchAddressDirectory()
        insertProblematicModels(addresses.map({ AddressNameModel(name: $0) }))
    }
    
    func insertProblematicModels(_ models: [any PersistentModel]) {
        print("LOG: problematic models \(models.count)")
        models.forEach {
            context.insert($0)
        }
        try? context.save() 
    }
    
    func insertModels(_ models: [any PersistentModel]) {
        print("LOG: insert models \(models.count)")
        models.forEach{( context.insert($0) )}
    }
}
