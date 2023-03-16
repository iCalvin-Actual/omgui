//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/6/23.
//

import SwiftUI

class SceneModel: ObservableObject {
    @ObservedObject
    var appModel: AppModel
    
    @Published
    var selectedAddress: AddressModel?
    @Published
    var selectedStatus: StatusModel?
    @Published
    var selectedNow: NowListing?
    @Published
    var selectedPURL: PURLModel?
    @Published
    var selectedPaste: PasteModel?
    
    @SceneStorage("app.lol.scene.address")
    var actingAddress: AddressName = "calvin"
    
    var addressBookFetcher: AddressBookDataFetcher
    
    var allBlocked: [AddressModel] {
        addressBookFetcher.blockedModel.listItems
    }
    
    var nonGlobalBlocked: [AddressModel] {
        let local = addressBookFetcher.blockedModel.localBloclistFetcher?.listItems ?? []
        let address = addressBookFetcher.blockedModel.addressBlocklistFetcher?.listItems ?? []
        return local + address
    }
    
    var destinationConstructor: DestinationConstructor {
        .init(sceneModel: self)
    }
    
    init(appModel: AppModel) {
        self.appModel = appModel
        self.addressBookFetcher = .init("", appModel: appModel)
    }
    
    func isBlocked(_ address: AddressName) -> Bool {
        allBlocked.map({ $0.name }).contains(address)
    }
    
    func canUnblock(_ address: AddressName) -> Bool {
        !addressBookFetcher.globalBlocklistFetcher.listItems.map({ $0.name }).contains(address)
    }
    
    func block(_ address: AddressName) {
        if !actingAddress.isEmpty {
            // Block to address
        }
        appModel.blockedAddresses.append(address)
        Task {
            await self.addressBookFetcher.update()
        }
    }
    
    func unBlock(_ address: AddressName) {
        if !actingAddress.isEmpty {
            // Unblock from address
        }
        appModel.blockedAddresses.removeAll(where: { $0 == address })
        Task {
            await self.addressBookFetcher.update()
        }
    }
}
