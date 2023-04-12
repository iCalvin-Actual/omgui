//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Foundation

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
        StatusLogDataFetcher(interface: interface)
    }
    
    func nowGardenFetcher() -> NowGardenDataFetcher {
        NowGardenDataFetcher(interface: interface)
    }
    
    func addressDetailsFetcher(_ address: AddressName, credential: APICredential?) -> AddressSummaryDataFetcher {
        AddressSummaryDataFetcher(name: address, credential: credential, interface: interface)
    }
    
    func addressProfileFetcher(_ address: AddressName) -> AddressProfileDataFetcher {
        AddressProfileDataFetcher(name: address, interface: interface)
    }
    
    func addressProfilePoster(_ address: AddressName, credential: APICredential) -> ProfileDraftPoster {
        let draft = AddressProfile.Draft(content: "", publish: true)
        return ProfileDraftPoster(address, draft: draft, interface: interface, credential: credential)
    }
    
    func addresNowFetcher(_ address: AddressName) -> AddressNowDataFetcher {
        AddressNowDataFetcher(name: address, interface: interface)
    }
    
    func addressPastesFetcher(_ address: AddressName) -> AddressPasteBinDataFetcher {
        AddressPasteBinDataFetcher(name: address, interface: interface)
    }
    
    func draftPastePoster(_ title: String, for address: AddressName, credential: APICredential) -> PasteDraftPoster {
        PasteDraftPoster(address, title: title, interface: interface, credential: credential)
    }
    
    func addressPURLsFetcher(_ address: AddressName) -> AddressPURLsDataFetcher {
        AddressPURLsDataFetcher(name: address, interface: interface)
    }
}
