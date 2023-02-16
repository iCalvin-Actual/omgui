//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 2/15/23.
//

import Foundation

/*
 Fetcher
 
 - Address Directory
 - Community Status Log
 - Global Settings
 - My Addresses
 - Blocklist
 - Following Status Log
 - My Status Log
 
 
 
 
 
 Directory Fetcher
 
 Profile Fetcher
 * Include PURL and Paste
 
 Global Status Fetcher
 
 Address Status Fetcher
 * Accepts array
 
 */

open class UIDataFetcher: ObservableObject {
    init() {
        update()
    }
    
    func update() {
        // Override in subclass
    }
}

open class AppModelDataFetcher: UIDataFetcher {
    
    @Published
    var serviceInfo: ServiceInfoModel?
    @Published
    var blockList: [AddressName] = []
    @Published
    var directory: [AddressModel] = []
    
    override init() {
        super.init()
    }
}

open class StatusLogDataFetcher: UIDataFetcher {
    let addresses: [AddressName]
    
    @Published
    var statuses: [StatusModel]
    
    init(addresses: [AddressName] = [], statuses: [StatusModel] = []) {
        self.addresses = addresses
        self.statuses = statuses
        super.init()
    }
}

open class AddressDetailsDataFetcher: UIDataFetcher {
    
    var addressName: AddressName
    
    @Published
    var verified: Bool?
    @Published
    var url: URL?
    @Published
    var registered: Date?
    
    @Published
    var profileFetcher: AddressProfileDataFetcher?
    @Published
    var nowFetcher: AddressNowDataFetcher?
    @Published
    var purlFetcher: AddressPURLsDataFetcher?
    @Published
    var pasteFetcher: AddressPasteBinDataFetcher?
    
    init(
        name: AddressName,
        profileFetcher: AddressProfileDataFetcher? = nil,
        nowFetcher: AddressNowDataFetcher? = nil,
        purlFetcher: AddressPURLsDataFetcher? = nil,
        pasteFetcher: AddressPasteBinDataFetcher? = nil
    ) {
        self.addressName = name
        self.profileFetcher = profileFetcher ?? .init(name: name)
        self.nowFetcher = nowFetcher ?? .init(name: name)
        self.purlFetcher = purlFetcher ?? .init(name: name)
        self.pasteFetcher = pasteFetcher ?? .init(name: name)
        super.init()
    }
    
    override func update() {
        verified = false
        registered = Date()
        url = URL(string: "https://\(addressName).omg.lol")
        profileFetcher?.update()
        nowFetcher?.update()
        purlFetcher?.update()
        pasteFetcher?.update()
    }
}

open class AddressProfileDataFetcher: UIDataFetcher {
    @Published
    var addressName: AddressName
    
    @Published
    var html: String?
    
    init(name: AddressName) {
        self.addressName = name
        super.init()
    }
}

open class AddressNowDataFetcher: UIDataFetcher {
    @Published
    var addressName: AddressName
    
    @Published
    var content: String?
    @Published
    var updated: Date?
    
    @Published
    var listed: Bool?
    
    init(name: AddressName) {
        self.addressName = name
        super.init()
    }
}

open class AddressPasteBinDataFetcher: UIDataFetcher {
    @Published
    var addressName: AddressName
    
    @Published
    var pastes: [PasteModel] = []
    
    init(name: AddressName) {
        self.addressName = name
        super.init()
    }
}

open class AddressPURLsDataFetcher: UIDataFetcher {
    @Published
    var addressName: AddressName
    
    @Published
    var purls: [PURLModel] = []
    
    init(name: AddressName) {
        self.addressName = name
        super.init()
    }
}
