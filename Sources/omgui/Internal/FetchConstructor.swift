//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Foundation

@MainActor
class FetchConstructor {
    let client: ClientInfo
    let interface: DataInterface
    
    init(client: ClientInfo, interface: DataInterface) {
        self.client = client
        self.interface = interface
    }
    
    func constructAccountModel() -> AccountModel {
        AccountModel(client: client, interface: interface)
    }
    
    func credentialFetcher() -> AccountAuthDataFetcher {
        AccountAuthDataFetcher(client: client, interface: interface)
    }
}
