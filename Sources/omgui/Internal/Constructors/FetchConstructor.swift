//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Blackbird
import Foundation
import SwiftUI

@MainActor
class FetchConstructor: ObservableObject {
    let client: ClientInfo
    let interface: DataInterface
    
    @ObservedObject
    var database: Blackbird.Database
    
    init(client: ClientInfo, interface: DataInterface, database: Blackbird.Database) {
        self.client = client
        self.interface = interface
        self.database = database
    }
    
    func addressDirectoryDataFetcher() -> AddressDirectoryDataFetcher {
        AddressDirectoryDataFetcher(interface: interface, db: database)
    }
    
    func generalStatusLog() -> StatusLogDataFetcher {
        StatusLogDataFetcher(title: "statusLog", interface: interface, db: database)
    }
    
    func nowGardenFetcher() -> NowGardenDataFetcher {
        NowGardenDataFetcher(interface: interface, db: database)
    }
    
    func statusLog(for addresses: [AddressName]) -> StatusLogDataFetcher {
        StatusLogDataFetcher(addresses: addresses, interface: interface, db: database)
    }
    
    func statusFetcher(_ id: String, from address: AddressName) -> StatusDataFetcher {
        return StatusDataFetcher(id: id, from: address, interface: interface, db: database)
    }
    
    func blockListFetcher(for address: AddressName, credential: APICredential?) -> AddressBlockListDataFetcher {
        AddressBlockListDataFetcher(address: address, credential: credential, interface: interface, db: database)
    }
    
    func followingFetcher(for address: AddressName, credential: APICredential?) -> AddressFollowingDataFetcher {
        AddressFollowingDataFetcher(address: address, credential: credential, interface: interface, db: database)
    }
    
    func accountInfoFetcher(for address: AddressName, credential: APICredential) -> AccountInfoDataFetcher? {
        guard !address.isEmpty else {
            return nil
        }
        return AccountInfoDataFetcher(address: address, interface: interface, credential: credential)
    }
    
    func accountAddressesDataFetcher(_ credential: String) -> AccountAddressDataFetcher {
        AccountAddressDataFetcher(credential: credential, interface: interface, db: database)
    }
    
    func addressDetailsFetcher(_ address: AddressName) -> AddressSummaryDataFetcher {
        AddressSummaryDataFetcher(name: address, interface: interface, database: database)
    }
    
    func addressPrivateDetailsFetcher(_ address: AddressName, credential: APICredential) -> AddressPrivateSummaryDataFetcher {
        AddressPrivateSummaryDataFetcher(name: address, interface: interface, credential: credential, database: database)
    }
    
    func addressProfileFetcher(_ address: AddressName) -> AddressProfileDataFetcher {
        AddressProfileDataFetcher(name: address, interface: interface, db: database)
    }
    
    func addresNowFetcher(_ address: AddressName) -> AddressNowDataFetcher {
        AddressNowDataFetcher(name: address, interface: interface, db: database)
    }
    
    func addressPastesFetcher(_ address: AddressName, credential: APICredential?) -> AddressPasteBinDataFetcher {
        AddressPasteBinDataFetcher(name: address, interface: interface, credential: credential, db: database)
    }
    
    func addressPasteFetcher(_ address: AddressName, title: String, credential: APICredential?) -> AddressPasteDataFetcher {
        AddressPasteDataFetcher(name: address, title: title, credential: credential, interface: interface, db: database)
    }
    
    func addressPURLsFetcher(_ address: AddressName, credential: APICredential?) -> AddressPURLsDataFetcher {
        AddressPURLsDataFetcher(name: address, interface: interface, credential: credential, db: database)
    }
    
    func addressPURLFetcher(_ address: AddressName, title: String, credential: APICredential?) -> AddressPURLDataFetcher {
        AddressPURLDataFetcher(name: address, title: title, credential: credential, interface: interface, db: database)
    }
    
    func draftPastePoster(_ title: String, for address: AddressName, credential: APICredential) -> PasteDraftPoster {
        PasteDraftPoster(address, title: title, interface: interface, credential: credential)
    }
    
    func draftPurlPoster(_ title: String, for address: AddressName, credential: APICredential) -> PURLDraftPoster {
        PURLDraftPoster(address, title: title, value: "", interface: interface, credential: credential, onPost: { _ in })
    }
    
    func draftStatusPoster(_ id: String? = nil, for address: AddressName, credential: APICredential) -> StatusDraftPoster {
        let draft = StatusModel.Draft(address: address, id: id, content: "", emoji: "")
        return StatusDraftPoster(address, draft: draft, interface: interface, credential: credential)
    }
}
