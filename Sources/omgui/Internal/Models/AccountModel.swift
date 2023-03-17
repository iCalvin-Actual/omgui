//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Combine
import SwiftUI

class AccountModel: DataFetcher {
    @AppStorage("app.lol.auth", store: .standard)
    var authKey: String = ""
    
    private let fetchConstructor: FetchConstructor
    
    private var authenticationFetcher: AccountAuthDataFetcher
    private var accountInfoFetcher: AccountInfoDataFetcher?
    
    private var requests: [AnyCancellable] = []
    
    init(fetchConstructor: FetchConstructor) {
        self.fetchConstructor = fetchConstructor
        self.authenticationFetcher = fetchConstructor.credentialFetcher()
        super.init(interface: fetchConstructor.interface)
        
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
        if !authKey.isEmpty, let first = addresses.first {
            self.accountInfoFetcher = fetchConstructor.accountInfoFetcher(for: first.name, credential: authKey)
            accountInfoFetcher?.$accountName.sink { [self] newValue in
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            }
            .store(in: &requests)
        } else {
            accountInfoFetcher = nil
        }
    }
    
    var displayName: String {
        accountInfoFetcher?.accountName ?? "anonymous"
    }
    
    var addresses: [AddressModel] = []
    
    var signedIn: Bool {
        !authKey.isEmpty
    }
    
    func authenticate() async {
        logout()
        Task {
            DispatchQueue.main.async {
                self.loading = true
            }
            await authenticationFetcher.update()
        }
    }
    
    func login(_ authKey: APICredential) async {
        DispatchQueue.main.async {
            self.authKey = authKey
            self.resetFetchers()
            self.fetchFinished()
            self.objectWillChange.send()
        }
    }
    
    func logout() {
        DispatchQueue.main.async {
            self.authKey = ""
            self.resetFetchers()
            self.objectWillChange.send()
        }
    }
    
    override func throwingUpdate() async throws {
        await accountInfoFetcher?.update()
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
