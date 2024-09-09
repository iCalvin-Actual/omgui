//
//  SceneModel.swift
//
//
//  Created by Calvin Chestnut on 3/6/23.
//

import AuthenticationServices
import Blackbird
import Combine
import SwiftUI

@MainActor
@Observable
class SceneModel {
    
    var database: Blackbird.Database
    
    let interface: DataInterface
    
    let addressBook: AddressBook
    
    // MARK: Caches
    
    var publicProfileCache: [AddressName: AddressSummaryDataFetcher] = [:]
    var privateProfileCache: [AddressName: AddressPrivateSummaryDataFetcher] = [:]
    
    // MARK: Properties
    
    var destinationConstructor: DestinationConstructor {
        .init(
            sceneModel: self
        )
    }
    
    // MARK: Lifecycle
    
    var cancellables: Set<AnyCancellable> = []
    
    let directoryFetcher: AddressDirectoryDataFetcher
    let gardenFetcher: NowGardenDataFetcher
    let statusFetcher: StatusLogDataFetcher
    
    init(
        addressBook: AddressBook,
        interface: DataInterface,
        database: Blackbird.Database
    )
    {
        self.addressBook = addressBook
        self.interface = interface
        self.database = database
        
        self.directoryFetcher = .init(addressBook: addressBook, interface: interface, db: database)
        self.gardenFetcher = .init(addressBook: addressBook, interface: interface, db: database)
        self.statusFetcher = .init(addressBook: addressBook, interface: interface, db: database)
        
        
        let myProfiles = addressBook.myAddresses
        let publicProfiles = (addressBook.pinnedAddresses + addressBook.following).filter({ !myProfiles.contains($0) })
        
        myProfiles.forEach({
            let privateAddress = $0
            Task {
                let _ = try addressPrivateSummary(privateAddress)
            }
        })
        publicProfiles.forEach({
            let _ = addressSummary($0)
        })
    }
}

// MARK: - AddressBook

extension SceneModel {
    enum AddressBookError: Error {
        case notYourAddress
    }
    
    // MARK: Summaries
    
    func constructFetcher(for address: AddressName) -> AddressSummaryDataFetcher {
        AddressSummaryDataFetcher(name: address, addressBook: addressBook, interface: interface, database: database)
    }
    func privateSummary(for address: AddressName) -> AddressPrivateSummaryDataFetcher? {
        guard addressBook.credential(for: address) != nil else {
            return nil
        }
        return AddressPrivateSummaryDataFetcher(name: address, addressBook: addressBook, interface: interface, database: database)
    }
    func addressSummary(_ address: AddressName) -> AddressSummaryDataFetcher {
        if let model = publicProfileCache[address] {
            return model
        } else {
            let model = constructFetcher(for: address)
            publicProfileCache[address] = model
            return model
        }
    }
    func addressPrivateSummary(_ address: AddressName) throws -> AddressPrivateSummaryDataFetcher {
        if let model = privateProfileCache[address] {
            return model
        } else {
            guard let model = privateSummary(for: address) else {
                throw AddressBookError.notYourAddress
            }
            privateProfileCache[address] = model
            return model
        }
    }
}
