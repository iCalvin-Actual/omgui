//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Combine
import Foundation
import SwiftUI

public class AppModel: ObservableObject {
    
    // MARK: - Definitions
    
    let client: ClientInfo
    let interface: DataInterface
    
    // MARK: Authentication
    var accountModel: AccountModel
    
    // MARK: Fetching
    
    internal var fetchConstructor: FetchConstructor
    private var profileModels: [AddressName: AddressSummaryDataFetcher] = [:]
    
    private var requests: [AnyCancellable] = []
    
    public init(client: ClientInfo, dataInterface: DataInterface) {
        self.client = client
        self.interface = dataInterface
        self.fetchConstructor = FetchConstructor(client: client, interface: dataInterface)
        self.accountModel = .init(fetchConstructor: fetchConstructor)
    }
    
    func addressDetails(_ address: AddressName) -> AddressSummaryDataFetcher {
        if let model = profileModels[address] {
            Task {
                await model.update()
            }
            return model
        } else {
            let newModel = fetchConstructor.addressDetailsFetcher(address)
            profileModels[address] = newModel
            return newModel
        }
    }
}
