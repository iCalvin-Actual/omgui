//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Foundation

class AccountModel: ObservableObject {
    var name: String = ""
    var addresses: [AddressModel] = []
    
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
