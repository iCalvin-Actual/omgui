//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 8/3/24.
//

import Foundation


extension AddressModel: QueryFilterable {
    var queryCheckStrings: [String] {
        [addressName]
    }
    
    var addressName: AddressName {
        id
    }
    
    var filterDate: Date? {
        registered
    }
}

extension NowListing: QueryFilterable {
    var queryCheckStrings: [String] {
        [addressName]
    }
    
    var addressName: AddressName {
        owner
    }
    
    var filterDate: Date? {
        updated
    }
}

extension PasteModel: QueryFilterable {
    var queryCheckStrings: [String] {
        [addressName, name, content]
            .compactMap({ $0 })
    }
    
    var addressName: AddressName {
        owner
    }
    
    var filterDate: Date? {
        nil
    }
}

extension PURLModel: QueryFilterable {
    var queryCheckStrings: [String] {
        [addressName, name, content]
            .compactMap({ $0 })
    }
    
    var addressName: AddressName {
        owner
    }
    
    var filterDate: Date? {
        nil
    }
}

extension StatusModel: QueryFilterable {
    var queryCheckStrings: [String] {
        [addressName, emoji, status]
            .compactMap({ $0 })
    }
    
    var addressName: AddressName {
        address
    }
    
    var filterDate: Date? {
        posted
    }
}
