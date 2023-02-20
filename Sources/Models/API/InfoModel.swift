//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 2/15/23.
//

import Foundation

public struct ServiceInfoModel: Hashable, Identifiable {
    let members: Int?
    let addresses: Int?
    let profiles: Int?
    
    init(members: Int? = nil, addresses: Int? = nil, profiles: Int? = nil) {
        self.members = members
        self.addresses = addresses
        self.profiles = profiles
    }
}
