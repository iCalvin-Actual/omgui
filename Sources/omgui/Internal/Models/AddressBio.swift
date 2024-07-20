//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import Foundation
import SwiftData

public struct AddressBioResponse: Sendable {
    let address: AddressName
    let bio: String?
    
    public init(address: AddressName, bio: String?) {
        self.address = address
        self.bio = bio
    }
}
