//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/6/23.
//

import Foundation

class SceneModel: ObservableObject {
    
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
    
    @Published
    var actingAddress: AddressName?
    
    init() {
    }
}
