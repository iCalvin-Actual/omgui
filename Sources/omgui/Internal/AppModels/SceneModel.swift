//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/6/23.
//

import Combine
import SwiftUI

@Observable
@MainActor
class SceneModel {
    
    let fetchConstructor: FetchConstructor
    
    var accountModel: AccountModel
    
    let addressBook: AddressBook
    
    var requests: [AnyCancellable] = []
    
    var editingModel: Editable?
    
    var destinationConstructor: DestinationConstructor {
        .init(
            addressBook: addressBook,
            accountModel: accountModel,
            fetchConstructor: fetchConstructor
        )
    }
    
    init(actingAddress: AddressName, fetchConstructor: FetchConstructor) {
        let account = fetchConstructor.constructAccountModel()
        self.fetchConstructor = fetchConstructor
        self.accountModel = account
        self.addressBook = AddressBook(actingAddress: actingAddress, accountModel: account, fetchConstructor: fetchConstructor)
    }
}
