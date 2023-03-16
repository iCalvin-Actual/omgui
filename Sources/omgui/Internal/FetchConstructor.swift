//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Foundation

class FetchConstructor: ObservableObject {
    let client: ClientInfo
    let interface: DataInterface
    
    private let directoryFetcher: AddressDirectoryDataFetcher
    private let globalStatusFetcher: StatusLogDataFetcher
    private let gardenFetcher: NowGardenDataFetcher
    
    init(client: ClientInfo, interface: DataInterface) {
        self.client = client
        self.interface = interface
        self.directoryFetcher = AddressDirectoryDataFetcher(interface: interface)
        self.globalStatusFetcher = StatusLogDataFetcher(interface: interface)
        self.gardenFetcher = NowGardenDataFetcher(interface: interface)
    }
    
    var directory: [AddressModel] {
        directoryFetcher.listItems
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
    
    func blockListFetcher(for address: AddressName) -> AddressBlockListDataFetcher {
        AddressBlockListDataFetcher(address: address, interface: interface)
    }
    
    func followingFetcher(for address: AddressName) -> AddressFollowingDataFetcher {
        AddressFollowingDataFetcher(address: address, interface: interface)
    }
    
    func addressDirectoryDataFetcher() -> AddressDirectoryDataFetcher {
        directoryFetcher
    }
    
    func accountAddressesDataFetcher(_ credential: String) -> AccountAddressDataFetcher {
        AccountAddressDataFetcher(interface: interface, credential: credential)
    }
    
    func statusLog(for addresses: [AddressName]) -> StatusLogDataFetcher {
        StatusLogDataFetcher(addresses: addresses, interface: interface)
    }
    
    func generalStatusLog() -> StatusLogDataFetcher {
        globalStatusFetcher
    }
    
    func nowGardenFetcher() -> NowGardenDataFetcher {
        gardenFetcher
    }
    
    func addressDetailsFetcher(_ address: AddressName) -> AddressSummaryDataFetcher {
        AddressSummaryDataFetcher(name: address, interface: interface)
    }
    
    func addressProfileFetcher(_ address: AddressName) -> AddressProfileDataFetcher {
        AddressProfileDataFetcher(name: address, interface: interface)
    }
    
    func addresNowFetcher(_ address: AddressName) -> AddressNowDataFetcher {
        AddressNowDataFetcher(name: address, interface: interface)
    }
    
    func addressPastesFetcher(_ address: AddressName) -> AddressPasteBinDataFetcher {
        AddressPasteBinDataFetcher(name: address, interface: interface)
    }
    
    func addressPURLsFetcher(_ address: AddressName) -> AddressPURLsDataFetcher {
        AddressPURLsDataFetcher(name: address, interface: interface)
    }
}
