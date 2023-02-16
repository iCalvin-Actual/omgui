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
 
 */


public protocol OMGDataFetcher {
    
    func fetchServiceInfo() async -> ServiceInfoModel
    
    func fetchGlobalBlocklist() async -> [AddressName] 
    
    func fetchAddressDirectory() async -> [AddressName]
    
    func fetchAddressProfile() async -> String?
    
    func fetchAddressInfo(_ name: AddressName) async -> AddressModel
    
    func fetchAddressPURLs(_ name: AddressName) async -> [PURLModel]
    
    func fetchAddressPastes(_ name: AddressName) async -> [PURLModel]
    
    func fetchStatusLog() async -> [StatusModel]
    
    func fetchAddressStatuses(addresses: [AddressName]) async -> [StatusModel]
    
}

open class SampleDataFetcher: OMGDataFetcher {
    public func fetchGlobalBlocklist() async -> [AddressName] {
        return []
    }
    
    public func fetchServiceInfo() async -> ServiceInfoModel {
        return .init(members: 0, addresses: 0, profiles: 0)
    }

    public func fetchAddressDirectory() async -> [AddressName] {
        return []
    }
    
    public func fetchAddressProfile() async -> String? {
        return nil
    }
    
    public func fetchAddressInfo(_ name: AddressName) async -> AddressModel {
        return .init(name: name, url: URL(string: "https://\(name).omg.lol"), registered: Date())
    }
    
    public func fetchAddressPURLs(_ name: AddressName) async -> [PURLModel] {
        return []
    } 
    
    public func fetchAddressPastes(_ name: AddressName) async -> [PURLModel] {
        return []
    }
    
    public func fetchStatusLog() async -> [StatusModel] {
        return []
    }
    
    public func fetchAddressStatuses(addresses: [AddressName]) async -> [StatusModel] {
        return []
    }
}

public class UIDataFetcher: ObservableObject {
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
    
    public override init() {
        super.init()
    }
}

open class StatusLogDataFetcher: UIDataFetcher {
    let addresses: [AddressName]
    
    @Published
    var statuses: [StatusModel]
    
    public init(addresses: [AddressName] = [], statuses: [StatusModel] = []) {
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
    
    public init(
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
    
    public init(name: AddressName) {
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
    
    public init(name: AddressName) {
        self.addressName = name
        super.init()
    }
}

open class AddressPasteBinDataFetcher: UIDataFetcher {
    @Published
    var addressName: AddressName
    
    @Published
    var pastes: [PasteModel] = []
    
    public init(name: AddressName) {
        self.addressName = name
        super.init()
    }
}

open class AddressPURLsDataFetcher: UIDataFetcher {
    @Published
    var addressName: AddressName
    
    @Published
    var purls: [PURLModel] = []
    
    public init(name: AddressName) {
        self.addressName = name
        super.init()
    }
}
