import Blackbird
import SwiftUI



public struct omgui: View {
    
    let clientInfo: ClientInfo
    let dataInterface: DataInterface
    
    // MARK: Storage
    
    @StateObject
    var database: Blackbird.Database
    
    @AppStorage("app.lol.terms")
    var acceptedTerms: TimeInterval = 0
    
    let termsUpdated: Date = .init(timeIntervalSince1970: 1726665286)
    
    @AppStorage("app.lol.auth")
    var authKey: String = ""
    
    @SceneStorage("app.lol.address")
    var actingAddress: String = ""
    
    @State
    var showOnboarding: Bool = false
    
    let accountAuthFetcher: AccountAuthDataFetcher
    
    let accountAddressesFetcher: AccountAddressDataFetcher
    let globalBlocklistFetcher: AddressBlockListDataFetcher
    
    
    public init(client: ClientInfo, interface: DataInterface, database: Blackbird.Database) {
        UITabBar.appearance().unselectedItemTintColor = UIColor.white
        self.clientInfo = client
        self.dataInterface = interface
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
        appState
            .sheet(isPresented: $showOnboarding, onDismiss: configureScene) {
                OnboardingView()
            }
    }
    
    @ViewBuilder
    private var appState: some View {
        if let sceneModel {
            RootView(
                sceneModel: sceneModel,
                accountAuthDataFetcher: accountAuthFetcher,
                db: database
            )
            .environment(\.colorScheme, .light)
            .environment(\.blackbirdDatabase, database)
            .onChange(of: authKey, { oldValue, newValue in
                accountAuthFetcher.configure($authKey)
                accountAddressesFetcher.configure(credential: authKey)
                Task { [accountAddressesFetcher] in
                    await accountAddressesFetcher.updateIfNeeded(forceReload: true)
                    self.configureAddressBook()
                    self.configureScene()
                }
            })
            .onChange(of: actingAddress, { oldValue, newValue in
                if !oldValue.isEmpty, !newValue.isEmpty, oldValue != newValue {
                    self.configureAddressBook()
                    self.configureScene()
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
                    configureAddressBook()
                    configureScene()
                }
            })
        } else if addressBook != nil {
            LoadingView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.lolOrange)
                .task {
                    if acceptedTerms < termsUpdated.timeIntervalSince1970 {
                        showOnboarding = true
                    } else {
                        configureScene()
                    }
                }
        } else {
            LoadingView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.lolPink)
                .task {
                    self.accountAuthFetcher.configure($authKey)
                    self.accountAddressesFetcher.configure(credential: authKey)
                    self.configureAddressBook()
                }
        }
    }
    
    private func configureAddressBook() {
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
    
    private func configureScene() {
        guard let addressBook else { return }
        self.sceneModel = .init(addressBook: addressBook, interface: dataInterface, database: database)
    }
}
