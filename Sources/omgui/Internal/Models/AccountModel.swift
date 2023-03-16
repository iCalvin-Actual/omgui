//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Combine
import SwiftUI

class AccountModel: ObservableObject {
    @AppStorage("app.lol.auth", store: .standard)
    private var authKey: String = ""
    
    private let fetchConstructor: FetchConstructor
    
    private var authenticationFetcher: AccountAuthDataFetcher
    private var myAddressesFetcher: AccountAddressDataFetcher?
    
    private var requests: [AnyCancellable] = []
    
    init(fetchConstructor: FetchConstructor) {
        self.fetchConstructor = fetchConstructor
        self.authenticationFetcher = fetchConstructor.credentialFetcher()
        
        authenticationFetcher.$authToken.sink { [self] newValue in
            let newValue = newValue ?? ""
            guard !newValue.isEmpty else {
                return
            }
            Task {
                await self.login(newValue)
            }
        }
        .store(in: &requests)
        self.resetFetchers()
    }
    
    func resetFetchers() {
        myAddressesFetcher = fetchConstructor.accountAddressesDataFetcher(authKey)
        myAddressesFetcher?.$listItems.sink { [self] newValue in
            print("Got new addresses")
            if actingAddress.isEmpty || !newValue.map({ $0.name }).contains(actingAddress) {
                actingAddress = newValue.first?.name ?? ""
            }
        }
        .store(in: &requests)
    }
    
    
    var name: String = ""
    var addresses: [AddressModel] = []
    
    var actingAddress: AddressName = ""
    
    var signedIn: Bool {
        !authKey.isEmpty
    }
    
    func authenticate() async {
        logout()
        Task {
            await authenticationFetcher.update()
        }
    }
    
    func login(_ authKey: APICredential) async {
        self.authKey = authKey
        self.objectWillChange.send()
    }
    
    func logout() {
        DispatchQueue.main.async {
            self.authKey = ""
            self.objectWillChange.send()
        }
        // Do logout things
    }
}

extension AccountModel {
    var blocked: [AddressName] {
        [
        ]
    }
    
    var following: [AddressName] {
        [
        ]
    }
    
    var pinned: [AddressName] {
        [
        ]
    }
}
