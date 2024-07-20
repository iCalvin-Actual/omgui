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
}
