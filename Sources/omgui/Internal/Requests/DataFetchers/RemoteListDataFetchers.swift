//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import Foundation

class AddressBioDataFetcher: DataFetcher {
    @Published
    var address: AddressName
    
    var bio: AddressBioModel?
    
    init(address: AddressName, interface: DataInterface) {
        self.address = address
        super.init(interface: interface)
    }
    
    override func throwingRequest() async throws {
        self.bio = try await interface.fetchAddressBio(address)
        await self.fetchFinished()
    }
}

