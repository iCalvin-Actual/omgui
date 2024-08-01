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
        interface: DataInterface,
        database: Blackbird.Database
    ) {
        self.addressName = name
        self.iconFetcher = .init(address: name, interface: interface, db: database)
        self.profileFetcher = .init(name: name, credential: nil, interface: interface, db: database)
        self.nowFetcher = .init(name: name, interface: interface, db: database)
        self.purlFetcher = .init(name: name, interface: interface, credential: nil, db: database)
        self.pasteFetcher = .init(name: name, interface: interface, credential: nil, db: database)
        self.statusFetcher = .init(addresses: [name], interface: interface, db: database)
        self.bioFetcher = .init(address: name, interface: interface)
        
        self.followingFetcher = .init(address: name, credential: nil, interface: interface, db: database)
        
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
    }
    
    override func throwingRequest() async throws {
        guard !addressName.isEmpty else {
            return
        }
        Task {
            url = URL(string: "https://\(addressName).omg.lol")
            let info = try await interface.fetchAddressInfo(addressName)
            self.verified = false
            self.registered = info.registered
            self.url = info.url
            
            self.fetchFinished()
        }
    }
}

@MainActor
class AddressPrivateSummaryDataFetcher: AddressSummaryDataFetcher {
    @ObservedObject
    var blockedFetcher: AddressBlockListDataFetcher
    
//    @ObservedObject
//    var profilePoster: ProfileDraftPoster
//    @ObservedObject
//    var nowPoster: NowDraftPoster
    
    init(
        name: AddressName,
        interface: DataInterface,
        credential: APICredential,
        database: Blackbird.Database
    ) {
        self.blockedFetcher = .init(address: name, credential: credential, interface: interface, db: database)
        
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
        
        super.init(name: name, interface: interface, database: database)
        
        self.profileFetcher = .init(name: addressName, credential: credential, interface: interface, db: database)
        self.followingFetcher = .init(address: addressName, credential: credential, interface: interface, db: database)
        
        self.purlFetcher = .init(name: addressName, interface: interface, credential: credential, db: database)
        self.pasteFetcher = .init(name: addressName, interface: interface, credential: credential, db: database)
    }
    
    override func perform() async {
        guard !addressName.isEmpty else {
            return
        }
        await super.perform()
        await blockedFetcher.perform()
    }
}

