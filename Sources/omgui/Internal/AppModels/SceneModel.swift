//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/6/23.
//

import AuthenticationServices
import Combine
import SwiftData
import SwiftUI

@Observable
@MainActor
class SceneModel {
    
    private var authenticationFetcher: AccountAuthDataFetcher?
    
    // App Storage
    @Binding
    @ObservationIgnored
    var authKey: String
    @Binding
    @ObservationIgnored
    var globalBlockedAddresses: String
    @Binding
    @ObservationIgnored
    var cachedBlockList: String
    @Binding
    @ObservationIgnored
    var currentlyPinnedAddresses: String
    @Binding
    @ObservationIgnored
    var localAddressesCache: String
    @Binding
    @ObservationIgnored
    var myName: String
    
    // Scene Storage
    @Binding
    @ObservationIgnored
    var actingAddress: AddressName
    
    let fetchConstructor: FetchConstructor
    
    
    var requests: [AnyCancellable] = []
    
    var context: ModelContext
    
    var editingModel: Editable?
    
    var destinationConstructor: DestinationConstructor {
        .init(
            sceneModel: self
        )
    }
    
    
    var globalBlocked: [AddressName] {
        get {
            let split = globalBlockedAddresses.split(separator: "&&&")
            return split.map({ String($0) })
        }
        set {
            // no op
        }
    }
    
    public var myAddresses: [String] {
        get {
            localAddressesCache.split(separator: "&&&").map({ String($0) })
        }
        set {
            localAddressesCache = newValue.joined(separator: "&&&")
        }
    }
    
    var pinnedAddresses: [AddressName] {
        get {
            let split = currentlyPinnedAddresses.split(separator: "&&&")
            return split.map({ String($0) })
        }
        set {
            currentlyPinnedAddresses = Array(Set(newValue)).joined(separator: "&&&")
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
    
    // MARK: No-Account Blocklist

    var localBlocklist: [AddressName] {
        get {
            let split = cachedBlockList.split(separator: "&&&")
            return split.map({ String($0) })
        }
        set {
            cachedBlockList = Array(Set(newValue)).joined(separator: "&&&")
        }
    }
    
    func unblock(_ address: AddressName) {
        localBlocklist.removeAll(where: { $0 == address })
    }
    func block(_ address: AddressName) {
        localBlocklist.append(address)
    }
    
    var signedIn: Bool {
        !authKey.isEmpty
    }
    
    init(
        fetchConstructor: FetchConstructor,
        context: ModelContext,
        authKey: Binding<String>,
        globalBlocklist: Binding<String>,
        localBlocklist: Binding<String>,
        pinnedAddresses: Binding<String>,
        myAddresses: Binding<String>,
        myName: Binding<String>,
        actingAddress: Binding<String>
    )
    {
        self._authKey = authKey
        self._globalBlockedAddresses = globalBlocklist
        self._cachedBlockList = localBlocklist
        self._currentlyPinnedAddresses = pinnedAddresses
        self._localAddressesCache = myAddresses
        self._myName = myName
        self._actingAddress = actingAddress
        self.fetchConstructor = fetchConstructor
        self.context = context
        self.authenticationFetcher = AccountAuthDataFetcher(sceneModel: self)
    }
    
    public func credential(for address: AddressName) -> APICredential? {
        guard !authKey.isEmpty, myAddresses.contains(address) else {
            return nil
        }
        return authKey
    }
    
    public func authenticate() {
        // Perform auth fetcher
        authenticationFetcher?.perform()
    }
    
    func login(_ incomingAuthKey: APICredential) {
        authKey = incomingAuthKey
    }
    
    func logout() {
        self.authKey = ""
        // todo: 'unload' my addresses first
        self.myAddresses = []
    }
    
    func fetchBio(_ address: AddressName) async throws {
        print("LOG: Fetching bio: \(address)")
        let bioResponse: AddressBioResponse = try await fetchConstructor.interface.fetchAddressBio(address)
        let model = AddressBioModel(bioResponse)
        insertModels([model])
    }
    
    func fetchStatusLog() async throws {
        print("LOG: fetching statusLog")
        let addressResponses = try await fetchConstructor.interface.fetchStatusLog()
        let models = addressResponses.map { StatusModel($0) }
        insertProblematicModels(models)
    }
    
    func fetchStatuses(_ addresses: [AddressName]) async throws {
        print("LOG: fetchBatchStatuses \(addresses)")
        let addressResponses = try await fetchConstructor.interface.fetchAddressStatuses(addresses: addresses)
        let models = addressResponses.map { StatusModel($0) }
        insertProblematicModels(models)
    }
    
    func fetchProfile(_ address: AddressName) async throws {
        print("LOG: ")
        if let profileResponse: AddressProfile = try await fetchConstructor.interface.fetchAddressProfile(address, credential: nil) {
            let model: AddressProfileModel = .init(profileResponse)
            insertModels([model])
        }
    }
    
    func fetchProfileContent(_ address: AddressName) async throws {
        print("LOG: fetching profile \(address)")
        let credential = credential(for: address)
        
        if let profileResponse: AddressProfile = try await fetchConstructor.interface.fetchAddressProfile(address, credential: credential) {
            let model: AddressProfileModel = .init(profileResponse)
            insertModels([model])
        }
    }
    
    func fetchNow(_ address: AddressName) async throws {
        print("LOG: ")
        let predicate = #Predicate<AddressNowListingModel> {
            $0.owner == address
        }
        let fetchDescriptor = FetchDescriptor<AddressNowListingModel>(predicate: predicate)
        let result = try context.fetch(fetchDescriptor).first
        if let nowResponse: NowModel = try await fetchConstructor.interface.fetchAddressNow(address) {
            let url = result?.url ?? "https://\(address).omg.lol/now"
            let model: AddressNowModel = .init(nowResponse, url: url)
            insertModels([model])
        }
    }
    
    func fetchNowGarden() async throws {
        print("LOG: fetching now garden")
        let listings = try await fetchConstructor.interface.fetchNowGarden()
        let models = listings.map({ AddressNowListingModel($0) })
        insertModels(models)
    }
        
    func fetchPURLS(_ address: AddressName) async throws {
        print("LOG: ")
        try await fetchPURLS([address])
    }
    
    func fetchPURLS(_ addresses: [AddressName]) async throws {
        print("LOG: fetching batch purls \(addresses)")
        for address in addresses {
            let credential = credential(for: address)
            async let purlsResponse = try fetchConstructor.interface.fetchAddressPURLs(address, credential: credential)
            let models = try await purlsResponse.map({ AddressPURLModel($0) })
            insertProblematicModels(models)
        }
    }
    
    func fetchPURL(_ address: AddressName, title: String) async throws {
        print("LOG: ")
        let credential = credential(for: address)
        
        if let purlResponse = try await fetchConstructor.interface.fetchPURL(title, from: address, credential: credential) {
            let model = AddressPURLModel(purlResponse)
            insertProblematicModels([model])
        }
    }
    
    func fetchPastes(_ address: AddressName) async throws {
        print("LOG: fetching address Pastes \(address)")
        try await fetchPastes([address])
    }
    
    func fetchPastes(_ addresses: [AddressName]) async throws {
        print("LOG: fetching batch pastes \(addresses)")
        for address in addresses {
            let credential = credential(for: address)
            async let pastesResponse = try fetchConstructor.interface.fetchAddressPastes(address, credential: credential)
            let models = try await pastesResponse.map({ AddressPasteModel($0) })
            insertModels(models)
        }
    }
    
    func fetchPaste(_ address: AddressName, title: String) async throws {
        print("LOG: fetching paste \(address)/\(title)")
        let credential = credential(for: address)
        
        if let purlResponse = try await fetchConstructor.interface.fetchPaste(title, from: address, credential: credential) {
            let model = AddressPasteModel(purlResponse)
            insertModels([model])
        }
    }
    
    func fetchInfo(_ address: AddressName) async throws {
        print("LOG: fetching info \(address)")
        fetchIcon(address)
        guard !address.isEmpty else {
            return
        }
        let info = try await fetchConstructor.interface.fetchAddressInfo(address)
        if let url = info.url {
            async let following = fetchConstructor.fetchFollowing(address)
            async let blocked = fetchConstructor.fetchBlocked(address)
            let infoModel = AddressInfoModel(owner: address, url: url, registered: info.registered ?? Date(), following: try await following, blocked: try await blocked)
            insertModels([infoModel])
        }
    }
    
    func fetchIcon(_ address: AddressName) {
        print("LOG: fetching icon (but not really) \(address)")
//        Task { [weak self] in
//            guard let self, !address.isEmpty, let url = address.addressIconURL else {
//                return
//            }
//            let request = URLRequest(url: url)
//            let (data, _) = try await URLSession.shared.data(for: request)
//            let iconModel = AddressIconModel(owner: address, imageData: data)
//            insertModels([iconModel])
//        }
    }
    
    func fetchDirectory() async throws {
        print("LOG: fetching directory")
        let addresses = try await fetchConstructor.interface.fetchAddressDirectory()
        insertProblematicModels(addresses.map({ AddressNameModel(name: $0) }))
    }
    
    func insertProblematicModels(_ models: [any PersistentModel]) {
        print("LOG: problematic models \(models.count)")
        models.forEach {
            context.insert($0)
        }
        try? context.save() 
    }
    
    func insertModels(_ models: [any PersistentModel]) {
        print("LOG: insert models \(models.count)")
        models.forEach{( context.insert($0) )}
    }
}
