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
    
    let addressBook: AddressBook
    
    var requests: [AnyCancellable] = []
    
    var context: ModelContext
    
    var editingModel: Editable?
    
    var destinationConstructor: DestinationConstructor {
        .init(
            addressBook: addressBook,
            accountModel: accountModel,
            fetchConstructor: fetchConstructor
        )
    }
    
    init(actingAddress: AddressName, fetchConstructor: FetchConstructor, context: ModelContext) {
        let account = fetchConstructor.constructAccountModel()
        self.fetchConstructor = fetchConstructor
        self.accountModel = account
        self.context = context
        self.addressBook = AddressBook(actingAddress: actingAddress, accountModel: account, fetchConstructor: fetchConstructor)
    }
    
    func fetchBio(_ address: AddressName) async throws {
        let bioResponse: AddressBioResponse = try await fetchConstructor.interface.fetchAddressBio(address)
        let model = AddressBioModel(bioResponse)
        insertModels([model])
    }
    
    func fetchStatusLog() async throws {
        let addressResponses = try await fetchConstructor.interface.fetchStatusLog()
        let models = addressResponses.map { StatusModel($0) }
        insertModels(models)
    }
    
    func fetchStatuses(_ addresses: [AddressName]) async throws {
        let addressResponses = try await fetchConstructor.interface.fetchAddressStatuses(addresses: addresses)
        let models = addressResponses.map { StatusModel($0) }
        insertModels(models)
    }
    
    func fetchProfile(_ address: AddressName) async throws {
        if let profileResponse: AddressProfile = try await fetchConstructor.interface.fetchAddressProfile(address, credential: nil) {
            let model: AddressProfileModel = .init(profileResponse)
            insertModels([model])
        }
    }
    
    func fetchProfileContent(_ address: AddressName) async throws {
        let credential = accountModel.credential(for: address, in: addressBook)
        
        if let profileResponse: AddressProfile = try await fetchConstructor.interface.fetchAddressProfile(address, credential: credential) {
            let model: AddressProfileModel = .init(profileResponse)
            insertModels([model])
        }
    }
    
    func fetchNow(_ address: AddressName) async throws {
        if let nowResponse: NowModel = try await fetchConstructor.interface.fetchAddressNow(address) {
            let model: AddressNowModel = .init(nowResponse)
            insertModels([model])
        }
    }
    
    func fetchPURLS(_ address: AddressName) async throws {
        try await fetchPURLS([address])
    }
    
    func fetchPURLS(_ addresses: [AddressName]) async throws {
        for address in addresses {
            let credential = accountModel.credential(for: address, in: addressBook)
            async let purlsResponse = try fetchConstructor.interface.fetchAddressPURLs(address, credential: credential)
            let models = try await purlsResponse.map({ AddressPURLModel($0) })
            insertModels(models)
        }
    }
    
    func fetchPURL(_ address: AddressName, title: String) async throws {
        let credential = accountModel.credential(for: address, in: addressBook)
        
        if let purlResponse = try await fetchConstructor.interface.fetchPURL(title, from: address, credential: credential) {
            let model = AddressPURLModel(purlResponse)
            insertModels([model])
        }
    }
    
    func fetchPastes(_ address: AddressName) async throws {
        try await fetchPURLS([address])
    }
    
    func fetchPastes(_ addresses: [AddressName]) async throws {
        for address in addresses {
            let credential = accountModel.credential(for: address, in: addressBook)
            async let pastesResponse = try fetchConstructor.interface.fetchAddressPastes(address, credential: credential)
            let models = try await pastesResponse.map({ AddressPasteModel($0) })
            insertModels(models)
        }
    }
    
    func fetchPaste(_ address: AddressName, title: String) async throws {
        let credential = accountModel.credential(for: address, in: addressBook)
        
        if let purlResponse = try await fetchConstructor.interface.fetchPaste(title, from: address, credential: credential) {
            let model = AddressPasteModel(purlResponse)
            insertModels([model])
        }
    }
    
    func fetchIcon(_ address: AddressName) async throws {
        guard !address.isEmpty, let url = address.addressIconURL else {
            return
        }
        let request = URLRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for: request)
        let iconModel = AddressIconModel(owner: address, data: data)
        insertModels([iconModel])
    }
    
    func fetchBlocked(_ address: AddressName = "app") async throws -> [AddressName] {
        let title = "app.lol.blocked"
        try await fetchPaste(address, title: title)
        let predicate = #Predicate<AddressPasteModel> {
            $0.id == "\(address)/\(title)"
        }
        let fetchDescriptor = FetchDescriptor<AddressPasteModel>(predicate: predicate)
        let result = try context.fetch(fetchDescriptor).first
        let list = result?.content?.components(separatedBy: .newlines).map({ String($0) }).filter({ !$0.isEmpty }) ?? []
        return list
    }
    
    func fetchFollowing(_ address: AddressName) async throws -> [AddressName] {
        let title = "app.lol.following"
        try await fetchPaste(address, title: title)
        let predicate = #Predicate<AddressPasteModel> {
            $0.id == "\(address)/\(title)"
        }
        let fetchDescriptor = FetchDescriptor<AddressPasteModel>(predicate: predicate)
        let result = try context.fetch(fetchDescriptor).first
        let list = result?.content?.components(separatedBy: .newlines).map({ String($0) }).filter({ !$0.isEmpty }) ?? []
        return list
    }
    
    private func insertModels(_ models: [any PersistentModel]) {
        Task { @MainActor in
            models.forEach {
                context.insert($0)
            }
            try? context.save()
        }
    }
}
