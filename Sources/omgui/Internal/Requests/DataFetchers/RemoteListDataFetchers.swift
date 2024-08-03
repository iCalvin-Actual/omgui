//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import Foundation

class AddressBioDataFetcher: DataFetcher {
    let address: AddressName
    
    var bio: AddressBioModel?
    
    init(address: AddressName, interface: DataInterface) {
        self.address = address
        super.init(interface: interface)
    }
    
    override func throwingRequest() async throws {
        Task {
            let bio = try await interface.fetchAddressBio(address)
            self.bio = bio
            self.fetchFinished()
        }
    }
}

