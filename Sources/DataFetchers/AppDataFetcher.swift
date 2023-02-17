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


public protocol OMGDataInterface {
    
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

class FetchConstructor: ObservableObject {
    let interface: OMGDataInterface
    init(interface: OMGDataInterface) {
        self.interface = interface
    }
    
    func appModelDataFetcher() -> AppModelDataFetcher {
        AppModelDataFetcher(interface: interface)
    }
    
    func statusLog(for addresses: [AddressName]) -> StatusLogDataFetcher {
        StatusLogDataFetcher(addresses: addresses, interface: interface)
    }
    
    func generalStatusLog() -> StatusLogDataFetcher {
        StatusLogDataFetcher(interface: interface)
    }
    
    func addressDetailsFetcher(_ address: AddressName) -> AddressDetailsDataFetcher {
        AddressDetailsDataFetcher(name: address, interface: interface)
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

class DataFetcher: ObservableObject {
    let interface: OMGDataInterface
    init(interface: OMGDataInterface) {
        self.interface = interface
        update()
    }
    
    func update() {
        // Override in subclass
    }
}

class AppModelDataFetcher: DataFetcher {
    
    @Published
    var serviceInfo: ServiceInfoModel?
    @Published
    var blockList: [AddressName] = []
    @Published
    var directory: [AddressModel] = []
    
    public override init(interface: OMGDataInterface) {
        super.init(interface: interface)
    }
}

class StatusLogDataFetcher: DataFetcher {
    let addresses: [AddressName]
    
    @Published
    var statuses: [StatusModel]
    
    public init(addresses: [AddressName] = [], statuses: [StatusModel] = [], interface: OMGDataInterface) {
        self.addresses = addresses
        self.statuses = statuses
        super.init(interface: interface)
    }
}

class AddressDetailsDataFetcher: DataFetcher {
    
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
        pasteFetcher: AddressPasteBinDataFetcher? = nil, interface: OMGDataInterface
    ) {
        self.addressName = name
        self.profileFetcher = profileFetcher ?? .init(name: name, interface: interface)
        self.nowFetcher = nowFetcher ?? .init(name: name, interface: interface)
        self.purlFetcher = purlFetcher ?? .init(name: name, interface: interface)
        self.pasteFetcher = pasteFetcher ?? .init(name: name, interface: interface)
        super.init(interface: interface)
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

class AddressProfileDataFetcher: DataFetcher {
    @Published
    var addressName: AddressName
    
    @Published
    var html: String?
    
    public init(name: AddressName, interface: OMGDataInterface) {
        self.addressName = name
        super.init(interface: interface)
    }
}

class AddressNowDataFetcher: DataFetcher {
    @Published
    var addressName: AddressName
    
    @Published
    var content: String?
    @Published
    var updated: Date?
    
    @Published
    var listed: Bool?
    
    public init(name: AddressName, interface: OMGDataInterface) {
        self.addressName = name
        super.init(interface: interface)
    }
}

class AddressPasteBinDataFetcher: DataFetcher {
    @Published
    var addressName: AddressName
    
    @Published
    var pastes: [PasteModel] = []
    
    public init(name: AddressName, interface: OMGDataInterface) {
        self.addressName = name
        super.init(interface: interface)
    }
}

class AddressPURLsDataFetcher: DataFetcher {
    @Published
    var addressName: AddressName
    
    @Published
    var purls: [PURLModel] = []
    
    public init(name: AddressName, interface: OMGDataInterface) {
        self.addressName = name
        super.init(interface: interface)
    }
}
