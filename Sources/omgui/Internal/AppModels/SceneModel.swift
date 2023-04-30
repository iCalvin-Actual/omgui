//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/6/23.
//

import Combine
import SwiftUI

class SceneModel: ObservableObject {
    
    let fetchConstructor: FetchConstructor
    
    let accountModel: AccountModel
    let addressBook: AddressBook
    
    var requests: [AnyCancellable] = []
    
    @Published
    var editingModel: DraftItem?
    
    var destinationConstructor: DestinationConstructor {
        .init(
            addressBook: addressBook,
            accountModel: accountModel,
            fetchConstructor: fetchConstructor
        )
    }
    
    init(fetchConstructor: FetchConstructor) {
        self.fetchConstructor = fetchConstructor
        self.accountModel = fetchConstructor.constructAccountModel()
        self.addressBook = AddressBook(accountModel: accountModel, fetchConstructor: fetchConstructor)
    }
}
