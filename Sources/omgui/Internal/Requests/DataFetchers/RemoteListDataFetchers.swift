//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import Blackbird
import Foundation

class AddressBioDataFetcher: DataFetcher {
    @Published
    var address: AddressName
    
    @Published
    var bio: AddressSummaryModel?
    
    init(address: AddressName, interface: DataInterface) {
        self.address = address
        super.init(interface: interface)
    }
    
    @MainActor
    override func throwingRequest() async throws {
        self.bio = try await interface.fetchAddressBio(address)
    }
}

