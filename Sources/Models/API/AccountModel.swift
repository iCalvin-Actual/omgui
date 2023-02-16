import SwiftUI

public class AccountModel: ObservableObject {
    var name: String = ""
    var addresses: [AddressModel] = []
    
    @Published
    var showingAccountModal: Bool = false
}

extension AccountModel {
    var blocked: [AddressName] {
        [
            "merlinmann"
        ]
    }
    
    var following: [AddressName] {
        [
            "app",
            "hotdogsladies"
        ]
    }
    
    var pinned: [AddressName] {
        [
            "calvin"
        ]
    }
}

