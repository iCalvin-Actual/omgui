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
        context.insert(model)
    }
    
    func fetchStatuses(_ addresses: [AddressName]) async throws {
        let addressResponses = try await fetchConstructor.interface.fetchAddressStatuses(addresses: addresses)
        let models = addressResponses.map { StatusModel($0) }
        models.forEach({ context.insert($0) })
    }
    
    func fetchProfile(_ address: AddressName) async throws {
        if let profileResponse: AddressProfile = try await fetchConstructor.interface.fetchAddressProfile(address, credential: nil) {
            let model: AddressProfileModel = .init(profileResponse)
            context.insert(model)
        }
    }
    
    func fetchProfileContent(_ address: AddressName) async throws {
        let credential = accountModel.credential(for: address, in: addressBook)
        
        if let profileResponse: AddressProfile = try await fetchConstructor.interface.fetchAddressProfile(address, credential: credential) {
            let model: AddressProfileModel = .init(profileResponse)
            context.insert(model)
        }
    }
    
    func fetchNow(_ address: AddressName) async throws {
        if let nowResponse: NowModel = try await fetchConstructor.interface.fetchAddressNow(address) {
            let model: AddressNowModel = .init(nowResponse)
            context.insert(model)
        }
    }
    
    func fetchPURL(_ address: AddressName, title: String) async throws {
        let credential = accountModel.credential(for: address, in: addressBook)
        
        if let purlResponse = try await fetchConstructor.interface.fetchPURL(title, from: address, credential: credential) {
            let model = AddressPURLModel(purlResponse)
            context.insert(model)
        }
    }
    
    func fetchPaste(_ address: AddressName, title: String) async throws {
        let credential = accountModel.credential(for: address, in: addressBook)
        
        do {
            if let purlResponse = try await fetchConstructor.interface.fetchPaste(title, from: address, credential: credential) {
                let model = AddressPasteModel(purlResponse)
                context.insert(model)
            }
        } catch {
            throw error
        }
    }
    
    func fetchIcon(_ address: AddressName) async throws {
        guard !address.isEmpty, let url = address.addressIconURL else {
            return
        }
        let request = URLRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for: request)
        let iconModel = AddressIconModel(owner: address, data: data)
        context.insert(iconModel)
    }
}
