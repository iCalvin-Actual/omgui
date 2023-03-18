//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import AuthenticationServices
import Combine
import SwiftUI
import Foundation

class DataFetcher: NSObject, ObservableObject {
    let interface: DataInterface
    
    @Published
    var loaded: Bool = false
    @Published
    var loading: Bool = false
    
    var error: Error?
    
    init(interface: DataInterface, autoLoad: Bool = true) {
        self.interface = interface
        super.init()
        if autoLoad {
            Task {
                await update()
            }
        }
    }
    
    func update() async {
        do {
            try await throwingUpdate()
        } catch {
            handle(error)
        }
    }
    
    func throwingUpdate() async throws {
        DispatchQueue.main.async {
            self.loading = true
        }
    }
    
    func fetchFinished() {
        DispatchQueue.main.async {
            self.loaded = true
            self.loading = false
            self.objectWillChange.send()
        }
    }
    
    func handle(_ error: Error) {
        DispatchQueue.main.async {
            self.loaded = false
            self.loading = false
            self.error = error
            self.objectWillChange.send()
        }
    }
    
    func threadSafeSendUpdate() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
}

class AccountAuthDataFetcher: DataFetcher, ASWebAuthenticationPresentationContextProviding {
    private var webSession: ASWebAuthenticationSession?
    
    private var url: URL?
    private var client: ClientInfo
    
    @Published
    var authToken: String?
    
    func recreateWebSession() {
        guard let url = url else {
            return
        }
        self.webSession = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: client.urlScheme
        ) { (callbackUrl, error) in
            guard let callbackUrl = callbackUrl else {
                if let error = error {
                    print("Error \(error)")
                } else {
                    print("Unknown error")
                }
                return
            }
            let components = URLComponents(url: callbackUrl, resolvingAgainstBaseURL: true)
            
            guard let code = components?.queryItems?.filter ({ $0.name == "code" }).first?.value else {
                return
            }
            let client = self.client
            Task {
                let token = try await self.interface.fetchAccessToken(
                    authCode: code,
                    clientID: client.id,
                    clientSecret: client.secret,
                    redirect: client.redirectUrl
                )
                self.authToken = token
            }
        }
        self.webSession?.presentationContextProvider = self
    }
    
    init(client: ClientInfo, interface: DataInterface) {
        self.client = client
        super.init(interface: interface, autoLoad: false)
        self.url = interface.authURL()
        self.recreateWebSession()
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
    
    override func throwingUpdate() async throws {
        recreateWebSession()
        DispatchQueue.main.async {
            self.webSession?.start()
        }
    }
    
    override func fetchFinished() {
        super.fetchFinished()
        recreateWebSession()
    }
}

class ListDataFetcher<T: Listable>: DataFetcher {
    
    @Published
    var listItems: [T] = []
    
    var title: String { "" }
    
    init(items: [T] = [], interface: DataInterface) {
        self.listItems = items
        super.init(interface: interface)
        self.loaded = items.isEmpty
    }
}

class AddressDirectoryDataFetcher: ListDataFetcher<AddressModel> {
    override var title: String {
        "app.lol"
    }
    
    override func throwingUpdate() async throws {
        try await super.throwingUpdate()
        Task {
            do {
                let directory = try await interface.fetchAddressDirectory()
                DispatchQueue.main.async {
                    self.listItems = directory.map({ AddressModel(name: $0) })
                    self.fetchFinished()
                }
            } catch {
                self.handle(error)
            }
        }
    }
}

class AccountInfoDataFetcher: DataFetcher {
    private let name: String
    private let credential: String
    
    @Published
    var accountName: String?
    
    init(address: AddressName, interface: DataInterface, credential: APICredential) {
        self.name = address
        self.credential = credential
        super.init(interface: interface)
    }
    
    override func throwingUpdate() async throws {
        let info = try await interface.fetchAccountInfo(name, credential: credential)
        DispatchQueue.main.async {
            self.accountName = info?.name
        }
    }
}

class AccountAddressDataFetcher: ListDataFetcher<AddressModel> {
    override var title: String {
        "my addresses"
    }
    private let credential: String
    
    init(interface: DataInterface, credential: APICredential) {
        self.credential = credential
        super.init(items: [], interface: interface)
    }
    
    override func throwingUpdate() async throws {
        try await super.throwingUpdate()
        Task {
            do {
                self.listItems = try await interface.fetchAccountAddresses(credential).map({ AddressModel(name: $0) })
                self.fetchFinished()
            } catch {
                self.handle(error)
            }
        }
    }
}

class AddressBioDataFetcher: DataFetcher {
    let address: AddressName
    
    @Published
    var bio: AddressBioModel?
    
    init(address: AddressName, interface: DataInterface) {
        self.address = address
        super.init(interface: interface)
    }
    
    override func throwingUpdate() async throws {
        try await super.throwingUpdate()
        Task {
            let bio = try await interface.fetchAddressBio(address)
            DispatchQueue.main.async {
                self.bio = bio
                self.fetchFinished()
            }
        }
    }
}

class AddressFollowingDataFetcher: ListDataFetcher<AddressModel> {
    let address: AddressName
    let credential: APICredential?
    let accountModel: AccountModel
    
    override var title: String {
        "following"
    }
    
    init(address: AddressName, credential: APICredential?, accountModel: AccountModel, interface: DataInterface) {
        self.address = address
        self.credential = credential
        self.accountModel = accountModel
        super.init(interface: interface)
    }
    
    override func throwingUpdate() async throws {
        try await super.throwingUpdate()
        Task {
            guard let content = try await interface.fetchPaste("app.lol.following", from: address, credential: credential)?.content else {
                self.fetchFinished()
                return
            }
            let list = content.components(separatedBy: .newlines).map({ String($0) }).filter({ !$0.isEmpty })
            self.handleItems(list)
        }
    }
    
    private func handleItems(_ addresses: [AddressName]) {
        DispatchQueue.main.async {
            self.listItems = addresses.map({ AddressModel(name: $0) })
            self.fetchFinished()
            self.threadSafeSendUpdate()
        }
    }
    
    func follow(_ toFollow: AddressName, credential: APICredential) {
        let newValue = Array(Set(self.listItems.map({ $0.name }) + [toFollow]))
        let newContent = newValue.joined(separator: "\n")
        let newPaste = PasteModel(
            owner: address,
            name: "app.lol.following",
            content: newContent
        )
        Task {
            let _ = try await self.interface.savePaste(newPaste, credential: credential)
            self.handleItems(newValue)
        }
    }
    
    func unFollow(_ toRemove: AddressName, credential: APICredential) {
        let newValue = listItems.map({ $0.name }).filter({ $0 != toRemove })
        let newContent = newValue.joined(separator: "\n")
        let newPaste = PasteModel(
            owner: address,
            name: "app.lol.following",
            content: newContent
        )
        Task {
            let _ = try await self.interface.savePaste(newPaste, credential: credential)
            self.handleItems(newValue)
        }
    }
}

class AddressBookDataFetcher: DataFetcher {
    let appModel: AppModel
    let address: AddressName
    
    let pinnedModel: PinnedListDataFetcher
    let followModel: AddressFollowingDataFetcher
    var localBlocklistFetcher: LocalBlockListDataFetcher
    var globalBlocklistFetcher: AddressBlockListDataFetcher
    var blockedModel: BlockListDataFetcher
    let directoryModel: AddressDirectoryDataFetcher
    
    var requests: [AnyCancellable] = []
    
    init(_ address: AddressName, credential: APICredential?, appModel: AppModel) {
        self.address = address
        self.appModel = appModel
        let fetchConstructor = appModel.fetchConstructor
        
        self.directoryModel = fetchConstructor.addressDirectoryDataFetcher()
        self.pinnedModel = PinnedListDataFetcher(interface: appModel.interface)
        self.localBlocklistFetcher = LocalBlockListDataFetcher(interface: appModel.interface)
        self.followModel = fetchConstructor.followingFetcher(for: address, credential: credential)
        self.globalBlocklistFetcher = fetchConstructor.blockListFetcher(for: "app", credential: nil)
        
        self.blockedModel = .init(
            globalFetcher: globalBlocklistFetcher,
            localFetcher: localBlocklistFetcher,
            addressFetcher: fetchConstructor.blockListFetcher(for: address, credential: credential),
            interface: appModel.interface)
        
        super.init(interface: appModel.interface)
        
        self.updateBlockedFetcher()
    }
    
    private func updateBlockedFetcher() {
        let credential: APICredential? = {
            guard appModel.accountModel.myAddressesFetcher?.listItems.map({ $0.name }).contains(address) ?? false else {
                return nil
            }
            return appModel.accountModel.authKey
        }()
        self.blockedModel = .init(
            globalFetcher: globalBlocklistFetcher,
            localFetcher: localBlocklistFetcher,
            addressFetcher: appModel.fetchConstructor.blockListFetcher(for: address, credential: credential),
            interface: interface
        )
        blockedModel.$listItems.sink(receiveValue: { _ in
            self.objectWillChange.send()
        }).store(in: &requests)
    }
}

class BlockListDataFetcher: ListDataFetcher<AddressModel> {
    override var title: String {
        "blocked"
    }
    
    let addressBlocklistFetcher: AddressBlockListDataFetcher?
    let globalBlocklistFetcher: AddressBlockListDataFetcher
    let localBloclistFetcher: LocalBlockListDataFetcher?
    
    var requests: [AnyCancellable] = []
    
    override var listItems: [AddressModel] {
        get {
            Array(Set((addressBlocklistFetcher?.listItems ?? []) + (localBloclistFetcher?.listItems ?? [])))
        }
        set {
        }
    }
    
    var allItems: [AddressModel] {
        listItems + globalBlocklistFetcher.listItems
    }
    
    init(
        globalFetcher: AddressBlockListDataFetcher,
        localFetcher: LocalBlockListDataFetcher? = nil,
        addressFetcher: AddressBlockListDataFetcher? = nil,
        interface: DataInterface
    ) {
        self.addressBlocklistFetcher = addressFetcher
        self.globalBlocklistFetcher = globalFetcher
        self.localBloclistFetcher = localFetcher
        
        super.init(interface: interface)
        
        globalBlocklistFetcher.$listItems.sink { globalItems in
            self.updateList()
        }.store(in: &requests)
        
        localBloclistFetcher?.$listItems.sink { localItems in
            self.updateList()
        }.store(in: &requests)
        
        addressBlocklistFetcher?.$listItems.sink { addressItems in
            self.updateList()
        }.store(in: &requests)
    }
    
    func updateList() {
        let local = localBloclistFetcher?.listItems ?? []
        let address = addressBlocklistFetcher?.listItems ?? []
        self.listItems = local + address
        self.fetchFinished()
        self.threadSafeSendUpdate()
    }
    
    func block(_ address: AddressName, credential: APICredential?) {
        if addressBlocklistFetcher != nil, let credential = credential {
            addressBlocklistFetcher?.block(address, credential: credential)
        }
        localBloclistFetcher?.insert(address)
    }
    
    func insertItems(_ newItems: [AddressModel]) {
        let toAdd = newItems.filter { !listItems.contains($0) }
        print("Appending \(toAdd.map({ $0.addressName })) to \(listItems.map({ $0.addressName })) in \(self)")
        DispatchQueue.main.async {
            self.listItems.append(contentsOf: toAdd)
            self.fetchFinished()
        }
    }
    
    override func throwingUpdate() async throws {
        try await globalBlocklistFetcher.throwingUpdate()
        try await localBloclistFetcher?.throwingUpdate()
        try await addressBlocklistFetcher?.throwingUpdate()
    }
}

class PinnedListDataFetcher: ListDataFetcher<AddressModel> {
    @AppStorage("app.lol.cache.pinned.history", store: .standard)
    private var pinnedAddressesHistory: String = "app"
    var previouslyPinnedAddresses: Set<AddressName> {
        get {
            let split = pinnedAddressesHistory.split(separator: "&&&")
            return Set(split.map({ String($0) }))
        }
        set {
            pinnedAddressesHistory = newValue.sorted().joined(separator: "&&&")
        }
    }
    
    @AppStorage("app.lol.cache.pinned", store: .standard)
    private var currentlyPinnedAddresses: String = "app"
    var pinnedAddresses: [AddressName] {
        get {
            let split = currentlyPinnedAddresses.split(separator: "&&&")
            return split.map({ String($0) })
        }
        set {
            currentlyPinnedAddresses = Array(Set(newValue)).joined(separator: "&&&")
            Task {
                await self.update()
            }
        }
    }
    
    override var title: String {
        "pinned"
    }
    
    override func throwingUpdate() async throws {
        DispatchQueue.main.async {
            self.listItems = self.pinnedAddresses.map({ AddressModel.init(name: $0) })
            self.fetchFinished()
        }
    }
    
    func isPinned(_ address: AddressName) -> Bool {
        pinnedAddresses.contains(address)
    }
    
    func pin(_ address: AddressName) {
        pinnedAddresses.append(address)
    }
    
    func removePin(_ address: AddressName) {
        pinnedAddresses.removeAll(where: { $0 == address })
    }
}

class LocalBlockListDataFetcher: ListDataFetcher<AddressModel> {
    
    // MARK: No-Account Blocklist
    @AppStorage("app.lol.cache.blocked", store: .standard)
    private var cachedBlockList: String = ""
    var blockedAddresses: [AddressName] {
        get {
            let split = cachedBlockList.split(separator: "&&&")
            return split.map({ String($0) })
        }
        set {
            cachedBlockList = Array(Set(newValue)).joined(separator: "&&&")
            Task {
                await self.update()
            }
        }
    }
    
    init(interface: DataInterface) {
        super.init(interface: interface)
        self.listItems = blockedAddresses.map({ AddressModel.init(name: $0) })
        
    }
    override var title: String {
        "blocked"
    }
    
    override func throwingUpdate() async throws {
        DispatchQueue.main.async {
            self.listItems = self.blockedAddresses.map({ AddressModel.init(name: $0) })
            self.fetchFinished()
            self.threadSafeSendUpdate()
        }
    }
    
    func remove(_ address: AddressName) {
        blockedAddresses.removeAll(where: { $0 == address })
    }
    
    func insert(_ address: AddressName) {
        blockedAddresses.append(address)
    }
}

class AddressBlockListDataFetcher: ListDataFetcher<AddressModel> {
    let address: AddressName
    let credential: APICredential?
    
    @ObservedObject
    var accountModel: AccountModel
    
    override var title: String {
        "blocked from \(address)"
    }
    
    init(address: AddressName, credential: APICredential?,  accountModel: AccountModel, interface: DataInterface) {
        self.address = address
        self.accountModel = accountModel
        self.credential = credential
        super.init(interface: interface)
    }
    
    override func throwingUpdate() async throws {
        try await super.throwingUpdate()
        let paste = try await interface.fetchPaste("app.lol.blocked", from: address, credential: accountModel.credential(for: address))
        let list = paste?.content?.components(separatedBy: .newlines).map({ String($0) }).filter({ !$0.isEmpty }) ?? []
        DispatchQueue.main.async {
            self.listItems = list.map({ AddressModel(name: $0) })
            self.fetchFinished()
        }
    }
    
    func block(_ toBlock: AddressName, credential: APICredential) {
        let newValue = Array(Set(self.listItems.map({ $0.name }) + [toBlock]))
        let newContent = newValue.joined(separator: "\n")
        let newPaste = PasteModel(
            owner: address,
            name: "app.lol.blocked",
            content: newContent
        )
        Task {
            let _ = try await self.interface.savePaste(newPaste, credential: credential)
            self.handleItems(newValue)
        }
        
    }
    
    func unBlock(_ toUnblock: AddressName, credential: APICredential) {
        let newValue = listItems.map({ $0.name }).filter({ $0 != toUnblock })
        let newContent = newValue.joined(separator: "\n")
        let newPaste = PasteModel(
            owner: address,
            name: "app.lol.blocked",
            content: newContent
        )
        Task {
            let _ = try await self.interface.savePaste(newPaste, credential: credential)
            self.handleItems(newValue)
        }
    }
    
    private func handleItems(_ addresses: [AddressName]) {
        DispatchQueue.main.async {
            self.listItems = addresses.map({ AddressModel(name: $0) })
            self.fetchFinished()
            self.threadSafeSendUpdate()
        }
    }
}

class StatusLogDataFetcher: ListDataFetcher<StatusModel> {
    let addresses: [AddressName]
    
    override var title: String {
        if addresses.count > 0 {
            return "following"
        } else {
            return "status.lol"
        }
    }
    
    init(addresses: [AddressName] = [], statuses: [StatusModel] = [], interface: DataInterface) {
        self.addresses = addresses
        super.init(items: statuses, interface: interface)
    }
    
    override func throwingUpdate() async throws {
        try await super.throwingUpdate()
        if addresses.isEmpty {
            Task {
                let statuses = try await interface.fetchStatusLog()
                DispatchQueue.main.async {
                    self.listItems = statuses
                    self.fetchFinished()
                }
            }
        } else {
            Task {
                let statuses = try await interface.fetchAddressStatuses(addresses: addresses)
                DispatchQueue.main.async {
                    self.listItems = statuses
                    self.fetchFinished()
                }
            }
        }
    }
}

class NowGardenDataFetcher: ListDataFetcher<NowListing> {
    override var title: String {
        "garden.lol"
    }
    override func throwingUpdate() async throws {
        try await super.throwingUpdate()
        Task {
            let garden = try await interface.fetchNowGarden()
            DispatchQueue.main.async {
                self.listItems = garden
                self.fetchFinished()
            }
        }
    }
}

class AddressProfileDataFetcher: DataFetcher {
    
    let addressName: AddressName
    let credential: APICredential?
    
    var html: String?
    
    init(name: AddressName, credential: APICredential? = nil, interface: DataInterface) {
        self.addressName = name
        self.credential = credential
        super.init(interface: interface)
    }
    
    override func throwingUpdate() async throws {
        try await super.throwingUpdate()
        Task {
            let profile = try await interface.fetchAddressProfile(addressName, credential: credential)
            self.html = profile?.content
            self.fetchFinished()
        }
    }
    
    var theme: String {
        return ""
    }
}

class AddressNowDataFetcher: DataFetcher {
    let addressName: AddressName
    
    var content: String?
    var updated: Date?
    
    var listed: Bool?
    
    init(name: AddressName, interface: DataInterface) {
        self.addressName = name
        super.init(interface: interface)
    }
    
    override func throwingUpdate() async throws {
        try await super.throwingUpdate()
        Task {
            let now = try await interface.fetchAddressNow(addressName)
            self.content = now?.content
            self.updated = now?.updated
            self.listed = now?.listed
            self.fetchFinished()
        }
    }
}

class AddressPasteBinDataFetcher: ListDataFetcher<PasteModel> {
    let addressName: AddressName
    
    override var title: String {
        "\(addressName).paste.lol"
    }
    
    init(name: AddressName, pastes: [PasteModel] = [], interface: DataInterface) {
        self.addressName = name
        super.init(items: pastes, interface: interface)
    }
    
    override func throwingUpdate() async throws {
        try await super.throwingUpdate()
        Task {
            let pastes = try await interface.fetchAddressPastes(addressName)
            DispatchQueue.main.async {
                self.listItems = pastes
                self.fetchFinished()
            }
        }
    }
}

class AddressPURLsDataFetcher: ListDataFetcher<PURLModel> {
    let addressName: AddressName
    
    override var title: String {
        "\(addressName).url.lol"
    }
    
    init(name: AddressName, purls: [PURLModel] = [], interface: DataInterface) {
        self.addressName = name
        super.init(items: purls, interface: interface)
    }
    
    override func throwingUpdate() async throws {
        try await super.throwingUpdate()
        Task {
            let purls = try await interface.fetchAddressPURLs(addressName)
            DispatchQueue.main.async {
                self.listItems = purls
                self.fetchFinished()
            }
        }
    }
}

class AddressSummaryDataFetcher: DataFetcher {
    
    let addressName: AddressName
    
    let accountModel: AccountModel
    
    var verified: Bool?
    var url: URL?
    var registered: Date?
    
    var profileFetcher: AddressProfileDataFetcher
    var nowFetcher: AddressNowDataFetcher
    var purlFetcher: AddressPURLsDataFetcher
    var pasteFetcher: AddressPasteBinDataFetcher
    var statusFetcher: StatusLogDataFetcher
    var bioFetcher: AddressBioDataFetcher
    
    var blockedFetcher: AddressBlockListDataFetcher
    var followingFetcher: AddressFollowingDataFetcher
    
    init(
        name: AddressName,
        profileFetcher: AddressProfileDataFetcher? = nil,
        nowFetcher: AddressNowDataFetcher? = nil,
        purlFetcher: AddressPURLsDataFetcher? = nil,
        pasteFetcher: AddressPasteBinDataFetcher? = nil,
        blockedFetcher: AddressBlockListDataFetcher? = nil,
        followingFetcher: AddressFollowingDataFetcher? = nil,
        accountModel: AccountModel,
        interface: DataInterface
    ) {
        self.addressName = name
        let credential = accountModel.credential(for: name)
        self.profileFetcher = profileFetcher ?? .init(name: name, credential: credential, interface: interface)
        self.nowFetcher = nowFetcher ?? .init(name: name, interface: interface)
        self.purlFetcher = purlFetcher ?? .init(name: name, interface: interface)
        self.pasteFetcher = pasteFetcher ?? .init(name: name, interface: interface)
        self.statusFetcher = .init(addresses: [name], interface: interface)
        self.bioFetcher = .init(address: name, interface: interface)
        
        self.blockedFetcher = blockedFetcher ?? .init(address: name, credential: credential, accountModel: accountModel, interface: interface)
        self.followingFetcher = followingFetcher ?? .init(address: name, credential: credential, accountModel: accountModel, interface: interface)
        self.accountModel = accountModel
        
        super.init(interface: interface)
    }
    
    override func throwingUpdate() async throws {
        try await super.throwingUpdate()
        Task {
            verified = false
            registered = Date()
            url = URL(string: "https://\(addressName).omg.lol")
            let info = try await interface.fetchAddressInfo(addressName)
            self.verified = false
            self.registered = info.registered
            self.url = info.url
            
            try await profileFetcher.throwingUpdate()
            try await nowFetcher.throwingUpdate()
            try await purlFetcher.throwingUpdate()
            try await pasteFetcher.throwingUpdate()
            try await statusFetcher.throwingUpdate()
            try await bioFetcher.throwingUpdate()
            try await followingFetcher.throwingUpdate()
            try await blockedFetcher.throwingUpdate()
            self.fetchFinished()
        }
    }
}
