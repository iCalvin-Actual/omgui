//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Foundation

public struct ServiceInfoModel {
    let members: Int?
    let addresses: Int?
    let profiles: Int?
    
    public init(members: Int? = nil, addresses: Int? = nil, profiles: Int? = nil) {
        self.members = members
        self.addresses = addresses
        self.profiles = profiles
    }
}

public struct AccountInfoModel {
    let name: String
    let created: Date
    
    public init(name: String, created: Date) {
        self.name = name
        self.created = created
    }
}

public struct ThemeModel: Codable {
    let id: String
    let name: String
    let created: String
    let updated: String
    let author: String
    let license: String
    let details: String
    let preview: String
    
    public enum CodingKeys: String, CodingKey {
        case id
        case name
        case created
        case updated
        case author
        case license
        case details = "description"
        case preview
    }
    
    
    public init(id: String, name: String, created: String, updated: String, author: String, license: String, description: String, preview: String) {
        self.id = id
        self.name = name
        self.created = created
        self.updated = updated
        self.author = author
        self.license = license
        self.details = description
        self.preview = preview
    }
}

public struct AddressProfile {
    let owner: AddressName
    let content: String
    
    public init(owner: AddressName, content: String) {
        self.owner = owner
        self.content = content
    }
}

public struct NowModel {
    let owner: AddressName
    
    let content: String?
    let html: String?
    let updated: Date?
    let listed: Bool?
    
    public init(owner: AddressName, content: String? = nil, html: String? = nil, updated: Date? = nil, listed: Bool? = nil) {
        self.owner = owner
        self.content = content
        self.html = html
        self.updated = updated
        self.listed = listed
    }
}

public struct PasteModel: Hashable, Identifiable, RawRepresentable, Codable {
    public var id: String { rawValue }
    static var separator: String { "{PASTE}" }
    
    public init?(rawValue: String) {
        let split = rawValue.split(separator: Self.separator)
        guard split.count == 3 else {
            return nil
        }
        self.owner = String(split[0])
        self.name = String(split[1])
        self.content = String(split[2])
        self.listed = true
    }
    
    public var rawValue: String {
        owner+Self.separator+name+Self.separator+(content ?? "")
    }
    public let owner: AddressName
    public let name: String
    public var content: String?
    public var listed: Bool
    
    public init(owner: AddressName, name: String, content: String? = nil, listed: Bool = true) {
        self.owner = owner
        self.name = name
        self.content = content
        self.listed = listed
    }
}

public struct PURLModel: Hashable, Identifiable, RawRepresentable, Codable {
    public var id: String { rawValue }
    static var separator: String { "{PURL}" }
    
    public init?(rawValue: String) {
        let split = rawValue.split(separator: Self.separator)
        guard split.count == 2 else {
            return nil
        }
        self.owner = String(split[0])
        self.value = String(split[1])
        self.listed = true
    }
    
    public var rawValue: String {
        owner+Self.separator+value
    }
    
    let owner: AddressName
    let value: String
    var destination: String?
    let listed: Bool
    
    var destinationURL: URL? {
        guard let string = destination else {
            return nil
        }
        return URL(string: string)
    }
    
    public init(owner: AddressName, value: String, destination: String? = nil, listed: Bool) {
        self.owner = owner
        self.destination = destination
        self.value = value
        self.listed = listed
    }
}

public struct NowListing: Hashable, Identifiable {
    public var id: String { owner+url }
    let owner: AddressName
    let url: String
    let updated: Date
    
    public init(owner: AddressName, url: String, updated: Date) {
        self.owner = owner
        self.url = url
        self.updated = updated
    }
}

public struct AddressModel: Hashable, Identifiable, RawRepresentable, Codable {
    public init?(rawValue: String) {
        self = AddressModel(name: rawValue)
    }
    
    public var rawValue: String { name }
    public var id: String { rawValue }
    
    let name: AddressName
    var url: URL?
    var registered: Date?
    
    public init(name: AddressName, url: URL? = nil, registered: Date? = nil) {
        self.name = name
        self.url = url
        self.registered = registered
    }
}

public struct StatusModel: Hashable, Identifiable {
    public let id: String
    let address: AddressName
    let posted: Date
    
    let status: String
    
    let emoji: String?
    let linkText: String?
    let link: URL?
    
    public init(id: String, address: AddressName, posted: Date, status: String, emoji: String? = nil, linkText: String? = nil, link: URL? = nil) {
        self.id = id
        self.address = address
        self.posted = posted
        self.status = status
        self.emoji = emoji
        self.linkText = linkText
        self.link = link
    }
    
    var displayEmoji: String {
        emoji ?? "✨"
    }
    
    var urlString: String {
        "https://\(address).status.lol/\(id)"
    }
    
    var primaryDestination: NavigationDestination {
        .statusLog(address)
    }
}

public struct GroupStatusLogModel {
    let displayTitle: String?
    let statuses: [StatusModel]
}
