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
    
    func accountInfoFetcher(for address: AddressName, credential: APICredential) -> AccountInfoDataFetcher? {
        guard !address.isEmpty else {
            return nil
        }
        return AccountInfoDataFetcher(address: address, interface: interface, credential: credential)
    }
    
    func credentialFetcher() -> AccountAuthDataFetcher {
        AccountAuthDataFetcher(client: client, interface: interface)
    }
    
    func blockListFetcher(for address: AddressName, credential: APICredential?) -> AddressBlockListDataFetcher {
        AddressBlockListDataFetcher(address: address, credential: credential, interface: interface)
    }
    
    func followingFetcher(for address: AddressName, credential: APICredential?) -> AddressFollowingDataFetcher {
        AddressFollowingDataFetcher(address: address, credential: credential, interface: interface)
    }
    
    func addressDirectoryDataFetcher() -> AddressDirectoryDataFetcher {
        AddressDirectoryDataFetcher(interface: interface)
    }
    
    func accountAddressesDataFetcher(_ credential: String) -> AccountAddressDataFetcher {
        AccountAddressDataFetcher(interface: interface, credential: credential)
    }
    
    func statusLog(for addresses: [AddressName]) -> StatusLogDataFetcher {
        StatusLogDataFetcher(addresses: addresses, interface: interface)
    }
    
    func generalStatusLog() -> StatusLogDataFetcher {
        StatusLogDataFetcher(title: "statusLog", interface: interface)
    }
    
    func nowGardenFetcher() -> NowGardenDataFetcher {
        NowGardenDataFetcher(interface: interface)
    }
    
    func addressDetailsFetcher(_ address: AddressName) -> AddressSummaryDataFetcher {
        AddressSummaryDataFetcher(name: address, interface: interface)
    }
    
    func addressPrivateDetailsFetcher(_ address: AddressName, credential: APICredential) -> AddressPrivateSummaryDataFetcher {
        AddressPrivateSummaryDataFetcher(name: address, interface: interface, credential: credential)
    }
    
    func addressPastesFetcher(_ address: AddressName, credential: APICredential?) -> AddressPasteBinDataFetcher {
        AddressPasteBinDataFetcher(name: address, interface: interface, credential: credential)
    }
    
    func addressPasteFetcher(_ address: AddressName, title: String, credential: APICredential?) -> AddressPasteDataFetcher {
        AddressPasteDataFetcher(name: address, title: title, interface: interface, credential: credential)
    }
    
    func addressPURLFetcher(_ address: AddressName, title: String, credential: APICredential?) -> AddressPURLDataFetcher {
        AddressPURLDataFetcher(name: address, title: title, interface: interface, credential: credential)
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
    
    func addressPURLsFetcher(_ address: AddressName, credential: APICredential?) -> AddressPURLsDataFetcher {
        AddressPURLsDataFetcher(name: address, interface: interface, credential: credential)
    }
}
