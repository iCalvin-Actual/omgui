//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import Foundation

public typealias APICredential = String
public typealias AddressName = String

struct CoreLists {
    let myAddresses: [AddressName]
    let following: [AddressName]
    let blocked: [AddressName]
    
    init(myAddresses: [AddressName] = [], following: [AddressName] = [], blocked: [AddressName] = []) {
        self.myAddresses = myAddresses
        self.following = following
        self.blocked = blocked
    }
}
