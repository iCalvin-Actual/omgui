import SwiftUI

public class AccountModel: ObservableObject {
    var name: String = ""
    var addresses: [AddressModel] = []
    
    @Published
    var showingAccountModal: Bool = false
    
    var signedIn: Bool {
        !addresses.isEmpty
    }
}

extension AccountModel {
    var blocked: [AddressName] {
        [
        ]
    }
    
    var following: [AddressName] {
        [
        ]
    }
    
    var pinned: [AddressName] {
        [
        ]
    }
}

