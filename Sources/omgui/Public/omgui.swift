import Blackbird
import SwiftUI

@Observable
final class AddressBook {
    
    let apiKey: APICredential
    let actingAddress: AddressName
    
    let accountAddressesFetcher: AccountAddressDataFetcher
    
    let globalBlocklistFetcher: AddressBlockListDataFetcher
    let localBlocklistFetcher: LocalBlockListDataFetcher
    let addressBlocklistFetcher: AddressBlockListDataFetcher
    
    let addressFollowingFetcher: AddressFollowingDataFetcher
    
    let pinnedAddressFetcher: PinnedListDataFetcher
    
    var myAddresses: [AddressName] {
        accountAddressesFetcher.results.map({ $0.addressName })
    }
    var myOtherAddresses: [AddressName] {
        myAddresses.filter({ $0 != actingAddress })
    }
    var globalBlocked: [AddressName] {
        globalBlocklistFetcher.results.map({ $0.addressName })
    }
    var addressBlocked: [AddressName] {
        addressBlocklistFetcher.results.map({ $0.addressName })
    }
    var localBlocked: [AddressName] {
        localBlocklistFetcher.results.map({ $0.addressName })
    }
    var following: [AddressName] {
        addressFollowingFetcher.results.map({ $0.addressName })
    }
    var pinnedAddresses: [AddressName] {
        pinnedAddressFetcher.pinnedAddresses
    }
    var appliedBlocked: [AddressName] {
        Array(Set(globalBlocked + visibleBlocked))
    }
    var visibleBlocked: [AddressName] {
        Array(Set(addressBlocked + localBlocked))
    }
    
    init(
        authKey: APICredential,
        actingAddress: AddressName,
        accountAddressesFetcher: AccountAddressDataFetcher,
        globalBlocklistFetcher: AddressBlockListDataFetcher,
        localBlocklistFetcher: LocalBlockListDataFetcher,
        addressBlocklistFetcher: AddressBlockListDataFetcher,
        addressFollowingFetcher: AddressFollowingDataFetcher,
        pinnedAddressFetcher: PinnedListDataFetcher
    ) {
        self.apiKey = authKey
        self.actingAddress = actingAddress
        self.accountAddressesFetcher = accountAddressesFetcher
        self.globalBlocklistFetcher = globalBlocklistFetcher
        self.localBlocklistFetcher = localBlocklistFetcher
        self.addressBlocklistFetcher = addressBlocklistFetcher
        self.addressFollowingFetcher = addressFollowingFetcher
        self.pinnedAddressFetcher = pinnedAddressFetcher
    }
    
    func autoFetch() async {
        await accountAddressesFetcher.updateIfNeeded(forceReload: true)
        await globalBlocklistFetcher.updateIfNeeded(forceReload: true)
        await localBlocklistFetcher.updateIfNeeded(forceReload: true)
        await addressBlocklistFetcher.updateIfNeeded(forceReload: true)
        await addressFollowingFetcher.updateIfNeeded(forceReload: true)
        await pinnedAddressFetcher.updateIfNeeded(forceReload: true)
    }
    
    func credential(for address: AddressName) -> APICredential? {
        guard myAddresses.contains(address) else {
            return nil
        }
        return apiKey
    }
    
    var signedIn: Bool {
        !apiKey.isEmpty
    }
    
    func pin(_ address: AddressName) async {
        await pinnedAddressFetcher.pin(address)
    }
    func removePin(_ address: AddressName) async {
        await pinnedAddressFetcher.removePin(address)
    }
    
    func block(_ address: AddressName) async {
        if let credential = credential(for: actingAddress) {
            await addressBlocklistFetcher.block(address, credential: credential)
        }
        await localBlocklistFetcher.insert(address)
    }
    func unblock(_ address: AddressName) async {
        if let credential = credential(for: actingAddress) {
            await addressBlocklistFetcher.unBlock(address, credential: credential)
        }
        await localBlocklistFetcher.remove(address)
    }
    
    func follow(_ address: AddressName) async {
        guard let credential = credential(for: actingAddress) else {
            return
        }
        await addressFollowingFetcher.follow(address, credential: credential)
    }
    func unFollow(_ address: AddressName) async {
        guard let credential = credential(for: address) else {
            return
        }
        await addressFollowingFetcher.unFollow(address, credential: credential)
    }
}

@MainActor
extension AddressBook {
    func isPinned(_ address: AddressName) -> Bool {
        pinnedAddresses.contains(address)
    }
    func isBlocked(_ address: AddressName) -> Bool {
        appliedBlocked.contains(address)
    }
    func canUnblock(_ address: AddressName) -> Bool {
        visibleBlocked.contains(address)
    }
    func isFollowing(_ address: AddressName) -> Bool {
        guard signedIn else {
            return false
        }
        return following.contains(address)
    }
    func canFollow(_ address: AddressName) -> Bool {
        guard signedIn else {
            return false
        }
        return !following.contains(address)
    }
    func canUnFollow(_ address: AddressName) -> Bool {
        guard signedIn else {
            return false
        }
        return following.contains(address)
    }
}

public struct omgui: View {
    
    let clientInfo: ClientInfo
    let dataInterface: DataInterface
    
    // MARK: Storage
    
    @StateObject
    var database: Blackbird.Database
    
    @AppStorage("app.lol.auth")
    var authKey: String = ""
    
    @SceneStorage("app.lol.address")
    var actingAddress: String = ""
    
    let accountAuthFetcher: AccountAuthDataFetcher
    
    let accountAddressesFetcher: AccountAddressDataFetcher
    let globalBlocklistFetcher: AddressBlockListDataFetcher
    
    
    public init(client: ClientInfo, interface: DataInterface, dbDestination: String = "") {
        self.clientInfo = client
        self.dataInterface = interface
        let database = try! Blackbird.Database(path: dbDestination)
        self._database = StateObject(wrappedValue: database)
        self.accountAuthFetcher = .init(authKey: nil, client: client, interface: interface)
        self.accountAddressesFetcher = .init(credential: "", interface: interface)
        self.globalBlocklistFetcher = .init(address: "app", credential: nil, interface: interface)
    }
    
    @State
    var addressBook: AddressBook?
    @State
    var sceneModel: SceneModel?
    
    public var body: some View {
        if let addressBook, let sceneModel {
            RootView(
                sceneModel: sceneModel,
                addressBook: addressBook,
                accountAuthDataFetcher: accountAuthFetcher,
                db: database
            )
            .environment(\.blackbirdDatabase, database)
            .onChange(of: authKey, { oldValue, newValue in
                print("Received auth key: \(newValue)")
                if !oldValue.isEmpty && newValue.isEmpty {
                    
                } else if accountAuthFetcher.authKey == nil {
                    accountAuthFetcher.configure($authKey)
                }
                accountAddressesFetcher.configure(credential: authKey)
                Task { [accountAddressesFetcher] in
                    await accountAddressesFetcher.updateIfNeeded(forceReload: true)
                }
            })
            .onReceive(accountAddressesFetcher.results.publisher, perform: { _ in
                accountAddressesFetcher.results.forEach { model in
                    let database = database
                    Task {
                        try await model.write(to: database)
                    }
                }
                if actingAddress.isEmpty, let address = accountAddressesFetcher.results.first {
                    actingAddress = address.addressName
                }
            })
        } else if let addressBook {
            LoadingView()
                .task {
                    self.sceneModel = .init(addressBook: addressBook, interface: dataInterface, database: database)
                }
        } else {
            LoadingView()
                .task {
                    self.accountAuthFetcher.configure($authKey)
                    self.accountAddressesFetcher.configure(credential: authKey)
                    self.addressBook = .init(
                        authKey: authKey,
                        actingAddress: actingAddress,
                        accountAddressesFetcher: accountAddressesFetcher,
                        globalBlocklistFetcher: globalBlocklistFetcher,
                        localBlocklistFetcher: .init(interface: dataInterface),
                        addressBlocklistFetcher: .init(address: actingAddress, credential: authKey, interface: dataInterface),
                        addressFollowingFetcher: .init(address: actingAddress, credential: authKey, interface: dataInterface),
                        pinnedAddressFetcher: .init(interface: dataInterface)
                    )
                }
        }
    }
}
