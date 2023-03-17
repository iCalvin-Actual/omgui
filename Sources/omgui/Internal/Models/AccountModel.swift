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
    
    @SceneStorage("app.lol.address")
    var actingAddress: AddressName = "" {
        didSet {
            print("SET UPDATE SOMEWHERE")
        }
    }
    
    private var fetchConstructor: FetchConstructor?
    
    private var authenticationFetcher: AccountAuthDataFetcher
    public var myAddressesFetcher: AccountAddressDataFetcher?
    private var accountInfoFetcher: AccountInfoDataFetcher?
    
    private var requests: [AnyCancellable] = []
    
    init(client: ClientInfo, interface: DataInterface) {
        self.authenticationFetcher = AccountAuthDataFetcher(client: client, interface: interface)
        super.init(interface: interface)
        
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
    
    func constructAccountAddressesFetcher(_ credential: APICredential) -> AccountAddressDataFetcher? {
        return AccountAddressDataFetcher(interface: interface, credential: credential)
    }
    
    func constructAccountInfoFetcher(_ name: AddressName, credential: APICredential) -> AccountInfoDataFetcher? {
        return AccountInfoDataFetcher(address: name, interface: interface, credential: credential)
    }
    
    func resetFetchers() {
        guard !authKey.isEmpty else {
            accountInfoFetcher = nil
            myAddressesFetcher = nil
            return
        }
        myAddressesFetcher = constructAccountAddressesFetcher(authKey)
        myAddressesFetcher?.$listItems.sink { addresses in
            self.addresses = addresses
            
            if let first = addresses.first {
                self.accountInfoFetcher = self.constructAccountInfoFetcher(first.name, credential: self.authKey)
                print("New fetcher")
                self.accountInfoFetcher?.$accountName.sink { [self] newValue in
                    DispatchQueue.main.async {
                        self.objectWillChange.send()
                    }
                }
                .store(in: &self.requests)
                
            }
        }
        .store(in: &requests)
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
    
    public func credential(for address: AddressName) -> APICredential? {
        guard !authKey.isEmpty, addresses.map({ $0.name }).contains(address) else {
            return nil
        }
        return authKey
    }
}
