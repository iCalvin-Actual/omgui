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
    
    private var authenticationFetcher: AccountAuthDataFetcher
    private var accountInfoFetcher: AccountInfoDataFetcher?
    
    init(client: ClientInfo, interface: DataInterface) {
        self.authenticationFetcher = AccountAuthDataFetcher(
            client: client,
            interface: interface
        )
        
        super.init(interface: interface)
        
        authenticationFetcher.$authToken.sink { newValue in
            let newValue = newValue ?? ""
            guard !newValue.isEmpty else {
                return
            }
            Task {
                await self.login(newValue)
            }
        }
        .store(in: &requests)
    }
    
    func login(_ incomingAuthKey: APICredential) async {
        authKey = incomingAuthKey
        Task {
            await perform()
        }
    }
    
    func logout() {
        authKey = ""
        Task {
            await perform()
        }
    }
    
    func constructAccountAddressesFetcher(_ credential: APICredential) -> AccountAddressDataFetcher? {
        return AccountAddressDataFetcher(interface: interface, credential: credential)
    }
    
    func constructAccountInfoFetcher(_ name: AddressName, credential: APICredential) -> AccountInfoDataFetcher? {
        return AccountInfoDataFetcher(address: name, interface: interface, credential: credential)
    }
    
    override func throwingRequest() async throws {
        guard !authKey.isEmpty else {
            accountInfoFetcher = nil
            threadSafeSendUpdate()
            return
        }
        self.accountInfoFetcher = self.constructAccountInfoFetcher("application", credential: self.authKey)
        self.accountInfoFetcher?.objectWillChange.sink { [self] _ in
            self.threadSafeSendUpdate()
        }
        .store(in: &self.requests)
    }
    
    var welcomeText: String {
        guard let accountName = accountInfoFetcher?.accountName else {
            return "app.lol"
        }
        return "Hello, \(accountName)"
    }
    
    var displayName: String {
        accountInfoFetcher?.accountName ?? ""
    }
    
    var signedIn: Bool {
        !authKey.isEmpty
    }
    
    func authenticate() async {
        logout()
        Task {
            await authenticationFetcher.perform()
        }
    }
    
    public func credential(for address: AddressName, in addressBook: AddressBook) -> APICredential? {
        guard !authKey.isEmpty, addressBook.myAddresses.contains(address) else {
            return nil
        }
        return authKey
    }
}
