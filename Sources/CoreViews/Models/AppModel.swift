import SwiftUI


@MainActor
@available(iOS 16.1, *)
public class AppModel: ObservableObject {
    
    @Published
    public var modelFetcher: AppModelDataFetcher
    
    @Published
    public var accountModel: AccountModel = .init()
                        
    @AppStorage("app.lol.auth", store: .standard)
    private var authKey: String = ""
    
    private var profileModels: [AddressName: AddressDetailsDataFetcher] = [:]
    
    internal init(fetcher: AppModelDataFetcher) {
        self.modelFetcher = fetcher
        Task {
            fetch()
        }
    }
    
    private func fetch() {
        
        modelFetcher.update()
        
    }
    
    public func login(_ authKey: String) {
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
    
    public func addressDetails(_ address: AddressName) -> AddressDetailsDataFetcher {
        if let model = profileModels[address] {
            return model
        } else {
            let newModel = AddressDetailsDataFetcher(name: address)
            profileModels[address] = newModel
            return newModel
        }
    }
}

internal extension AppModel {
    var directory: [AddressModel] { modelFetcher.directory }
}
