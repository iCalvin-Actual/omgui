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
    
    var accountModel: AccountModel
    
    let addressBook: AddressBook
    
    var requests: [AnyCancellable] = []
    
    @Published
    var editingModel: Editable?
    
    @Published
    var presentUpsellModal: Bool = false
    
    var destinationConstructor: DestinationConstructor {
        .init(
            addressBook: addressBook,
            accountModel: accountModel,
            fetchConstructor: fetchConstructor
        )
    }
    
    init(fetchConstructor: FetchConstructor) {
        let account = fetchConstructor.constructAccountModel()
        self.fetchConstructor = fetchConstructor
        self.accountModel = account
        self.addressBook = AddressBook(accountModel: account, fetchConstructor: fetchConstructor)
    }
}
