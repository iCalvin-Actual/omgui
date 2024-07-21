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
    
    func draftPastePoster(_ title: String, for address: AddressName, credential: APICredential) -> PasteDraftPoster {
        PasteDraftPoster(address, title: title, interface: interface, credential: credential)
    }
    
    func draftPurlPoster(_ title: String, for address: AddressName, credential: APICredential) -> PURLDraftPoster {
        PURLDraftPoster(address, title: title, value: "", interface: interface, credential: credential, onPost: { _ in })
    }
    
    func statusFetcher(_ id: String, from address: AddressName) -> StatusDataFetcher {
        return StatusDataFetcher(id: id, from: address, interface: interface)
    }
    
    func draftStatusPoster(_ id: String? = nil, for address: AddressName, credential: APICredential) -> StatusDraftPoster {
        let draft = StatusResponse.Draft(address: address, id: id, content: "", emoji: "")
        return StatusDraftPoster(address, draft: draft, interface: interface, credential: credential)
    }
}
