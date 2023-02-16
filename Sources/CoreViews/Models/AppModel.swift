import SwiftUI

@MainActor
@available(iOS 16.1, *)
public class AppModel: ObservableObject {
    
    public static var state: AppModel = {
        AppModel()
    }()
    
    @Published
    public var accountAddresses: [AddressModel] = []
    @Published
    public var addressDirectory: DirectoryModel = .init()
    
    @Published
    public var accountModel: AccountModel = .init()
                        
    @AppStorage("app.lol.auth", store: .standard)
    private var authKey: String = ""
    
    private var profileModels: [AddressName: AddressDetailModels] = [:]
    
    private init() {
        Task {
            fetch()
        }
    }
    
    private func fetch() {
        
        // Fetch Directory
        addressDirectory.fetch()
        
        // Fetch Recent Status Log
        //    TBD: Does that include X most recent, or the most recent from each address?
        
        // Fetch service info
        
        // Combile list of addresses to fetch
        //     Self, pinned
        // Create view models and insert into store
        
        // Fetch Nows
        
    }
    
    public func login(_ authKey: String) {
        Task {
            let addresses = [
                "app",
                "calvin"
            ]
            for address in addresses {
                guard !self.profileModels.keys.contains(address) else {
                    continue
                }
                self.profileModels[address] = .init(address: .init(address))
            }
            
            
        }
    }
    
    public func addressDetails(_ address: AddressName) -> AddressDetailModels {
        if let model = profileModels[address] {
            return model
        } else {
            let newModel = AddressDetailModels(address: address)
            profileModels[address] = newModel
            return newModel
        }
    }
}
