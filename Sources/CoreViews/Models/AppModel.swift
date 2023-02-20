import SwiftUI


@MainActor
@available(iOS 16.1, *)
class AppModel: ObservableObject {
    
    @ObservedObject
    internal var modelFetcher: AppModelDataFetcher
    
    @Published
    public var accountModel: AccountModel = .init()
                        
    @AppStorage("app.lol.auth", store: .standard)
    private var authKey: String = ""
    
    private var profileModels: [AddressName: AddressDetailsDataFetcher] = [:]
    
    internal var fetchConstructor: FetchConstructor
    
    internal init(interface: OMGDataInterface) {
        self.fetchConstructor = FetchConstructor(interface: interface)
        self.modelFetcher = fetchConstructor.appModelDataFetcher()

        Task {
            fetch()
        }
    }
    
    private func fetch() {
        Task {
            await self.modelFetcher.update()
        }
        
        // Fetch pinned addresses
        
        // Fetch
    }
    
    internal func login(_ authKey: String) {
        Task {
            let addresses = [
                "app",
                "calvin"
            ]
            for address in addresses {
                let _ = addressDetails(address)
            }
        }
    }
    
    internal func addressDetails(_ address: AddressName) -> AddressDetailsDataFetcher {
        if let model = profileModels[address] {
            return model
        } else {
            let newModel = fetchConstructor.addressDetailsFetcher(address)
            profileModels[address] = newModel
            return newModel
        }
    }
}

@available(iOS 16.1, *)
@available(macCatalyst 16.1, *)
internal extension AppModel {
    var directory: [AddressModel] { modelFetcher.directory }
}
