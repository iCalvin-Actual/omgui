//
//  AddressSummaryDataFetchers.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import Blackbird
import Combine
import Foundation
import SwiftUI

class AddressSummaryDataFetcher: DataFetcher {
    
    let addressName: AddressName
    
    var verified: Bool?
    var url: URL?
    var registered: Date?
    
    var iconURL: URL? {
        addressName.addressIconURL
    }
    
    var iconFetcher: AddressIconDataFetcher
    var profileFetcher: AddressProfileDataFetcher
    var nowFetcher: AddressNowDataFetcher
    var purlFetcher: AddressPURLsDataFetcher
    var pasteFetcher: AddressPasteBinDataFetcher
    var statusFetcher: StatusLogDataFetcher
    var bioFetcher: AddressBioDataFetcher
    
    var followingFetcher: AddressFollowingDataFetcher
    
    init(
        name: AddressName,
        addressBook: AddressBook,
        interface: DataInterface,
        database: Blackbird.Database
    ) {
        self.addressName = name
        self.iconFetcher = .init(address: name, interface: interface, db: database)
        self.profileFetcher = .init(name: name, credential: nil, interface: interface, db: database)
        self.nowFetcher = .init(name: name, interface: interface, db: database)
        self.purlFetcher = .init(name: name, credential: nil, addressBook: addressBook, interface: interface, db: database)
        self.pasteFetcher = .init(name: name, credential: nil, addressBook: addressBook, interface: interface, db: database)
        self.statusFetcher = .init(addresses: [name], addressBook: addressBook, interface: interface, db: database)
        self.bioFetcher = .init(address: name, interface: interface)
        
        self.followingFetcher = .init(address: name, credential: nil, interface: interface)
        
        super.init(interface: interface)
    }
    
    override func perform() async {
        guard !addressName.isEmpty else {
            return
        }
        await super.perform()
        
        await iconFetcher.updateIfNeeded()
        await profileFetcher.updateIfNeeded()
        await nowFetcher.updateIfNeeded()
        await purlFetcher.updateIfNeeded()
        await pasteFetcher.updateIfNeeded()
        await statusFetcher.updateIfNeeded()
        await bioFetcher.updateIfNeeded()
        await followingFetcher.updateIfNeeded()
        
        await fetchFinished()
    }
    
    override func throwingRequest() async throws {
        guard !addressName.isEmpty else {
            return
        }
        url = URL(string: "https://\(addressName).omg.lol")
        let info = try await interface.fetchAddressInfo(addressName)
        self.verified = false
        self.registered = info.date
        self.url = info.url
        
        await self.fetchFinished()
    }
}

class AddressPrivateSummaryDataFetcher: AddressSummaryDataFetcher {
    let blockedFetcher: AddressBlockListDataFetcher
    
//    @ObservedObject
//    var profilePoster: ProfileDraftPoster
//    @ObservedObject
//    var nowPoster: NowDraftPoster
    
    override init(
        name: AddressName,
        addressBook: AddressBook,
        interface: DataInterface,
        database: Blackbird.Database
    ) {
        self.blockedFetcher = .init(address: name, credential: addressBook.apiKey, interface: interface, db: database)
        
//        self.profilePoster = .init(
//            name,
//            draftItem: .init(
//                address: name,
//                content: "",
//                publish: true
//            ),
//            interface: interface,
//            credential: credential
//        )!
//        self.nowPoster = .init(
//            name,
//            draftItem: .init(
//                address: name,
//                content: "",
//                listed: true
//            ),
//            interface: interface,
//            credential: credential
//        )!
        
        super.init(name: name, addressBook: addressBook, interface: interface, database: database)
        
        self.profileFetcher = .init(name: addressName, credential: addressBook.apiKey, interface: interface, db: database)
        self.followingFetcher = .init(address: addressName, credential: addressBook.apiKey, interface: interface)
        
        self.purlFetcher = .init(name: addressName, credential: addressBook.apiKey, addressBook: addressBook, interface: interface, db: database)
        self.pasteFetcher = .init(name: addressName, credential: addressBook.apiKey, addressBook: addressBook, interface: interface, db: database)
    }
    
    override func perform() async {
        guard !addressName.isEmpty else {
            return
        }
        await blockedFetcher.perform()
        await super.perform()
    }
}

