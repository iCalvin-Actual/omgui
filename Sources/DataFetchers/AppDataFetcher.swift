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
    
    func fetchNowGarden() async -> [NowListing]
    
    func fetchAddressProfile(_ name: AddressName) async -> String?
    
    func fetchAddressInfo(_ name: AddressName) async -> AddressModel
    
    func fetchAddressNow(_ name: AddressName) async -> NowModel
    
    func fetchAddressPURLs(_ name: AddressName) async -> [PURLModel]
    
    func fetchAddressPastes(_ name: AddressName) async -> [PasteModel]
    
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
    
    func nowGardenFetcher() -> NowGardenDataFetcher {
        NowGardenDataFetcher(interface: interface)
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
    
    override func update() {
        Task {
            let directory = await interface.fetchAddressDirectory().map { AddressModel(name: $0) }
            self.directory = directory
        }
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
    
    override func update() {
        Task {
            if addresses.isEmpty {
                let statuses = await interface.fetchStatusLog()
                self.statuses = statuses
            } else {
                let statuses = await interface.fetchAddressStatuses(addresses: addresses)
                self.statuses = statuses
            }
        }
    }
}

class NowGardenDataFetcher: DataFetcher {
    
    @Published
    var gerden: [NowListing] = []
    
    public override init(interface: OMGDataInterface) {
        super.init(interface: interface)
    }
    
    override func update() {
        Task {
            self.gerden = await interface.fetchNowGarden()
        }
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
        Task {
            verified = false
            registered = Date()
            url = URL(string: "https://\(addressName).omg.lol")
            let info = await interface.fetchAddressInfo(addressName)
            self.verified = false
            self.registered = info.registered
            self.url = info.url            
        }
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
    
    override func update() {
        Task {
            let profile = await interface.fetchAddressProfile(addressName)
            self.html = profile
        }
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
    
    override func update() {
        Task {
            let now = await interface.fetchAddressNow(addressName)
            self.content = now.content
            self.updated = now.updated
            self.listed = true
        }
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
    
    override func update() {
        var pastes: [PasteModel] = []
        for _ in 0..<10 {
            guard let paste = PasteModel.random(from: addressName) else {
                continue
            }
            pastes.append(paste)
        }
        self.pastes = pastes
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
    
    override func update() {
        var purls: [PURLModel] = []
        for _ in 0..<10 {
            guard let purl = PURLModel.random(from: addressName) else {
                continue
            }
            purls.append(purl)
        }
        self.purls = purls
    }
}
