//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/6/23.
//

import Combine
import SwiftUI

class SceneModel: ObservableObject {
    @ObservedObject
    var appModel: AppModel
    
    var addressBookFetcher: AddressBookDataFetcher
    
    var requests: [AnyCancellable] = []
    
    var destinationConstructor: DestinationConstructor {
        .init(sceneModel: self)
    }
    
    @ObservedObject
    var addressBook: AddressBookModel
    
    init(appModel: AppModel) {
        self.appModel = appModel
        self.addressBook = .init(appModel: appModel)
        self.addressBookFetcher = .init("", credential: appModel.accountModel.authKey, appModel: appModel)
        
        appModel.$accountModel.sink { model in
            print("model \(model.signedIn)")
        }
        .store(in: &requests)
    }
}
