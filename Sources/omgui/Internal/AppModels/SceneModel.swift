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
    
    @SceneStorage("app.lol.address")
    var actingAddress: AddressName = "" {
        didSet {
            print("SET UPDATE SOMEWHERE")
        }
    }
    
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
        self.addressBookFetcher = .init("", appModel: appModel)
    }
}
