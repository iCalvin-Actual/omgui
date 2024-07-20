//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/19/24.
//

import Foundation
import SwiftData

@Model
final class StatusModel {
    var id: String
    var address: AddressName
    var posted: Date
    
    var status: String
    
    var emoji: String?
    
    convenience init(_ status: StatusResponse) {
        self.init(id: status.id, address: status.address, posted: status.posted, status: status.status, emoji: status.emoji)
    }
    
    init(id: String, address: AddressName, posted: Date, status: String, emoji: String? = nil) {
        self.id = id
        self.address = address
        self.posted = posted
        self.status = status
        self.emoji = emoji
    }
}

@Model
final class AddressBioModel {
    var address: AddressName
    var bio: String
    
    public convenience init(_ model: AddressBioResponse) {
        self.init(address: model.address, bio: model.bio ?? "")
    }
    
    public init(address: AddressName, bio: String = "") {
        self.address = address
        self.bio = bio
    }
}

@Model
final class AddressWebpageModel {
    var owner: AddressName
    var content: String
    
    convenience init(_ profile: AddressProfile) {
        self.init(owner: profile.owner, content: profile.content)
    }
    
    init(owner: AddressName, content: String) {
        self.owner = owner
        self.content = content
    }
}

@Model
final class AddressProfileModel {
    var owner: AddressName
    var content: String
    
    convenience init(_ profile: AddressProfile) {
        self.init(owner: profile.owner, content: profile.content)
    }
    
    init(owner: AddressName, content: String) {
        self.owner = owner
        self.content = content
    }
}

extension DataInterface {
    var swiftModels: [any PersistentModel.Type] {
        [
            AddressBioModel.self,
            StatusModel.self,
            AddressWebpageModel.self,
            AddressProfileModel.self
        ]
    }
}
