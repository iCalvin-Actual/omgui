import AuthenticationServices
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
    
    func authURL() -> URL?
    
    func fetchAccessToken(authCode: String, clientID: String, clientSecret: String, redirect: String) async throws -> String?
    
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
@available(iOS 16.1, *)
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
    
    func credentialFetcher(_ model: AppModel) -> AccountAuthDataFetcher {
        AccountAuthDataFetcher(interface: interface, appModel: model)
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
class DataFetcher: NSObject, ObservableObject {
    let interface: OMGDataInterface
    
    @Published
    var loaded: Bool = false
    @Published
    var loading: Bool = false
    
    init(interface: OMGDataInterface) {
        self.interface = interface
        super.init()
        Task {
            await update()
        }
    }
    
    func update() async {
        self.loading = true
    }
}

@available(iOS 16.1, *)
class AccountAuthDataFetcher: DataFetcher, ASWebAuthenticationPresentationContextProviding {
    private var webSeession: ASWebAuthenticationSession?
    
    var model: AppModel
    
    init(interface: OMGDataInterface, appModel: AppModel) {
        self.model = appModel
        super.init(interface: interface)
        guard let url = interface.authURL() else {
            return
        }
        self.webSeession = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: "app-omg-lol"
        ) { (url, error) in
            guard let url = url else {
                if let error = error {
                    print("Error \(error)")
                } else {
                    print("Unknown error")
                }
                return
            }
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            
            guard let code = components?.queryItems?.filter ({ $0.name == "code" }).first?.value else {
                // Bad url response?
                print("url: \(url)")
                return
            }
            Task {
                let token = try await interface.fetchAccessToken(
                    authCode: code, 
                    clientID: AppModel.clientId, 
                    clientSecret: AppModel.clientSecret, 
                    redirect: AppModel.clientRedirect
                )
                if let token = token {
                    self.model.login(token)
                }
            }
        }
        self.webSeession?.presentationContextProvider = self
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
    
    override func update() async {
        self.webSeession?.start()
    }
    
    
}

class ListDataFetcher<T: Listable>: DataFetcher {
    
    @Published
    var listItems: [T] = []
    
    public init(items: [T] = [], interface: OMGDataInterface) {
        self.listItems = items
        super.init(interface: interface)
        self.loaded = items.isEmpty
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
            self.directory = directory
        }
    }
}

class AddressDirectoryDataFetcher: ListDataFetcher<AddressModel> {
    override func update() async {
        await super.update()
        Task {
            let directory = await interface.fetchAddressDirectory()
            self.listItems = directory.map({ AddressModel(name: $0) })
            self.loaded = true
            self.loading = false
        }
    }
}

class StatusLogDataFetcher: ListDataFetcher<StatusModel> {
    let addresses: [AddressName]
    
    public init(addresses: [AddressName] = [], statuses: [StatusModel] = [], interface: OMGDataInterface) {
        self.addresses = addresses
        super.init(items: statuses, interface: interface)
        
    }
    
    override func update() async {
        await super.update()
        Task {
            if addresses.isEmpty {
                let statuses = await interface.fetchStatusLog()
                self.listItems = statuses
            } else {
                let statuses = await interface.fetchAddressStatuses(addresses: addresses)
                self.listItems = statuses
                self.loaded = true
                self.loading = false
            }
        }
    }
}

class NowGardenDataFetcher: ListDataFetcher<NowListing> {
    override func update() async {
        await super.update()
        Task {
            let garden = await interface.fetchNowGarden()
            self.listItems = garden
            self.loaded = true
            self.loading = false
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
        await super.update()
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
            self.loaded = true
            self.loading = false
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
        await super.update()
        Task {
            let profile = await interface.fetchAddressProfile(addressName)
            self.html = profile
            self.loaded = true
            self.loading = false
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
        await super.update()
        Task {
            let now = await interface.fetchAddressNow(addressName)
            self.content = now?.content
            self.updated = now?.updated
            self.listed = now?.listed
            self.loaded = true
            self.loading = false
        }
    }
}

class AddressPasteBinDataFetcher: ListDataFetcher<PasteModel> {
    var addressName: AddressName
    
    public init(name: AddressName, pastes: [PasteModel] = [], interface: OMGDataInterface) {
        self.addressName = name
        super.init(items: pastes, interface: interface)
    }
    
    override func update() async {
        await super.update()
        Task {
            let pastes = await interface.fetchAddressPastes(addressName)
            self.listItems = pastes
            self.loaded = true
            self.loading = false
        }
    }
}

class AddressPURLsDataFetcher: ListDataFetcher<PURLModel> {
    var addressName: AddressName
    
    public init(name: AddressName, purls: [PURLModel] = [], interface: OMGDataInterface) {
        self.addressName = name
        super.init(items: purls, interface: interface)
    }
    
    override func update() async {
        await super.update()
        Task {
            let purls = await interface.fetchAddressPURLs(addressName)
            self.listItems = purls
            self.loaded = true
            self.loading = false
        }
    }
}
