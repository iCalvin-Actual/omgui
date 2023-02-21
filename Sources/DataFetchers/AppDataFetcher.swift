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
    
    func fetchServiceInfo() async throws -> ServiceInfoModel
    
    func fetchGlobalBlocklist() async -> [AddressName] 
    
    func fetchAddressDirectory() async -> [AddressName]
    
    func fetchNowGarden() async -> [NowListing]
    
    func fetchAddressProfile(_ name: AddressName) async -> String?
    
    func fetchAddressInfo(_ name: AddressName) async -> AddressModel
    
    func fetchAddressNow(_ name: AddressName) async -> NowModel?
    
    func fetchAddressPURLs(_ name: AddressName) async -> [PURLModel]
    
    func fetchAddressPastes(_ name: AddressName) async -> [PasteModel]
    
    func fetchStatusLog() async -> [StatusModel]
    
    func fetchAddressStatuses(addresses: [AddressName]) async -> [StatusModel]
    
}

@MainActor
class FetchConstructor: ObservableObject {
    let interface: OMGDataInterface
    
    private let directoryFetcher: AddressDirectoryDataFetcher
    private let globalStatusFetcher: StatusLogDataFetcher
    private let gardenFetcher: NowGardenDataFetcher
    
    init(interface: OMGDataInterface) {
        self.interface = interface
        self.directoryFetcher = AddressDirectoryDataFetcher(interface: interface)
        self.globalStatusFetcher = StatusLogDataFetcher(interface: interface)
        self.gardenFetcher = NowGardenDataFetcher(interface: interface)
    }
    
    func appModelDataFetcher() -> AppModelDataFetcher {
        AppModelDataFetcher(interface: interface)
    }
    
    func addressDirectoryDataFetcher() -> AddressDirectoryDataFetcher {
        directoryFetcher
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

@MainActor
class DataFetcher: ObservableObject {
    let interface: OMGDataInterface
    init(interface: OMGDataInterface) {
        self.interface = interface
        Task {
            await update()
        }
    }
    
    func update() async {
        // Override in subclass
    }
}

class AppModelDataFetcher: ObservableObject {
    
    var serviceInfo: ServiceInfoModel?
    var blockList: [AddressName] = []

    @Published
    var directory: [AddressModel] = []
    let interface: OMGDataInterface
    
    init(interface: OMGDataInterface) {
        self.interface = interface
        Task {
            await update()
        }
    }
    
    func update() async {
        Task {
            let directory = await interface.fetchAddressDirectory().map { AddressModel(name: $0) }
            DispatchQueue.main.async {
                self.directory = directory
            }
        }
    }
}

class AddressDirectoryDataFetcher: DataFetcher {
    @Published
    var directory: [AddressModel] = []
    
    override public init(interface: OMGDataInterface) {
        super.init(interface: interface)
    }
    
    override func update() async {
        Task {
            let directory = await interface.fetchAddressDirectory()
            self.directory = directory.map({ AddressModel(name: $0) })
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
    
    override func update() async {
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
    
    override func update() async {
        Task {
            let garden = await interface.fetchNowGarden()
            DispatchQueue.main.async {
                self.gerden = garden
            }
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
    var profileFetcher: AddressProfileDataFetcher
    @Published
    var nowFetcher: AddressNowDataFetcher
    @Published
    var purlFetcher: AddressPURLsDataFetcher
    @Published
    var pasteFetcher: AddressPasteBinDataFetcher
    @Published
    var statusFetcher: StatusLogDataFetcher
    
    public init(
        name: AddressName,
        profileFetcher: AddressProfileDataFetcher? = nil,
        nowFetcher: AddressNowDataFetcher? = nil,
        purlFetcher: AddressPURLsDataFetcher? = nil,
        pasteFetcher: AddressPasteBinDataFetcher? = nil,
        interface: OMGDataInterface
    ) {
        self.addressName = name
        self.profileFetcher = profileFetcher ?? .init(name: name, interface: interface)
        self.nowFetcher = nowFetcher ?? .init(name: name, interface: interface)
        self.purlFetcher = purlFetcher ?? .init(name: name, interface: interface)
        self.pasteFetcher = pasteFetcher ?? .init(name: name, interface: interface)
        self.statusFetcher = .init(addresses: [name], interface: interface)
        super.init(interface: interface)
    }
    
    override func update() async {
        Task {
            verified = false
            registered = Date()
            url = URL(string: "https://\(addressName).omg.lol")
            let info = await interface.fetchAddressInfo(addressName)
            self.verified = false
            self.registered = info.registered
            self.url = info.url
            
            await profileFetcher.update()
            await nowFetcher.update()
            await purlFetcher.update()
            await pasteFetcher.update()
        }
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
    
    override func update() async {
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
    
    override func update() async {
        Task {
            let now = await interface.fetchAddressNow(addressName)
            self.content = now?.content
            self.updated = now?.updated
            self.listed = now?.listed
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
    
    override func update() async {
        Task {
            let pastes = await interface.fetchAddressPastes(addressName)
            self.pastes = pastes
        }
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
    
    override func update() async {
        Task {
            let purls = await interface.fetchAddressPURLs(addressName)
            self.purls = purls
        }
    }
}
