//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Blackbird
import Foundation

public struct ServiceInfoModel: Sendable {
    let members: Int?
    let addresses: Int?
    let profiles: Int?
    
    public init(members: Int? = nil, addresses: Int? = nil, profiles: Int? = nil) {
        self.members = members
        self.addresses = addresses
        self.profiles = profiles
    }
}

public struct AddressAvailabilityModel: Sendable {
    let address: AddressName
    let available: Bool
    let punyCode: String?
    
    public init(address: AddressName, available: Bool, punyCode: String? = nil) {
        self.address = address
        self.available = available
        self.punyCode = punyCode
    }
}

public struct AccountInfoModel: Sendable {
    let name: String
    let created: Date
    
    public init(name: String, created: Date) {
        self.name = name
        self.created = created
    }
}

public struct ThemeModel: Codable, Sendable {
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

struct AddressIconModel: BlackbirdModel {
    
    var addressName: AddressName { id }
    
    @BlackbirdColumn
    var id: AddressName
    @BlackbirdColumn
    var data: Data?
    
    enum CodingKeys: String, BlackbirdCodingKey {
        case id
        case data
    }
    
    init(_ row: Blackbird.ModelRow<AddressIconModel>) {
        self.init(id: row[\.$id], data: row[\.$data])
    }
    
    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(AddressName.self, forKey: .id)
        if let data = try container.decodeIfPresent(Data.self, forKey: .data) {
            self.data = data
        }
    }
    
    init(id: AddressName, data: Data? = nil) {
        self.id = id
        self.data = data
    }
}

public struct AddressProfile: BlackbirdModel, Sendable {
    var owner: AddressName { id }
    @BlackbirdColumn
    public var id: AddressName
    @BlackbirdColumn
    var content: String
    
    enum CodingKeys: String, BlackbirdCodingKey {
        case id
        case content
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._id = try container.decode(BlackbirdColumn<AddressName>.self, forKey: .id)
        self._content = try container.decode(BlackbirdColumn<String>.self, forKey: .content)
    }
    
    public init(_ row: Blackbird.ModelRow<AddressProfile>) {
        self.init(owner: row[\.$id], content: row[\.$content])
    }
    
    public init(owner: AddressName, content: String) {
        self.id = owner
        self.content = content
    }
}

public struct NowModel: BlackbirdModel, Sendable {
    
    @BlackbirdColumn
    public var id: AddressName
    @BlackbirdColumn
    var content: String?
    @BlackbirdColumn
    var html: String?
    @BlackbirdColumn
    var updated: Date?
    @BlackbirdColumn
    var listed: Bool?
    
    var owner: AddressName { id }
    
    enum CodingKeys: String, BlackbirdCodingKey {
        case id
        case content
        case html
        case updated
        case listed
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(AddressName.self, forKey: .id)
        self.content = try container.decodeIfPresent(String.self, forKey: .content)
        self.html = try container.decodeIfPresent(String.self, forKey: .html)
        self.updated = try container.decodeIfPresent(Date.self, forKey: .updated)
        self.listed = try container.decodeIfPresent(Bool.self, forKey: .listed)
    }
    
    public init(_ row: Blackbird.ModelRow<NowModel>) {
        self.init(
            owner: row[\.$id],
            content: row[\.$content],
            html: row[\.$html],
            updated: row[\.$updated],
            listed: row[\.$listed]
        )
    }
    
    public init(
        owner: AddressName,
        content: String? = nil,
        html: String? = nil,
        updated: Date? = nil,
        listed: Bool? = nil
    ) {
        self.id = owner
        self.content = content
        self.html = html
        self.updated = updated
        self.listed = listed
    }
}

public struct PasteModel: BlackbirdModel, Identifiable, RawRepresentable, Codable, Sendable {
    
    static var separator: String { "{PASTE}" }
    
    public var rawValue: String {
        [owner, name].joined(separator: Self.separator)
    }
    
    @BlackbirdColumn
    public var id: String
    @BlackbirdColumn
    public var owner: AddressName
    @BlackbirdColumn
    public var name: String
    @BlackbirdColumn
    public var content: String
    @BlackbirdColumn
    public var listed: Bool
    
    enum CodingKeys: String, BlackbirdCodingKey {
        case id
        case owner
        case name
        case content
        case listed
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        owner = try container.decode(AddressName.self, forKey: .owner)
        name = try container.decode(String.self, forKey: .name)
        content = try container.decode(String.self, forKey: .content)
        listed = try container.decode(Bool.self, forKey: .listed)
    }
    
    public init(_ row: Blackbird.ModelRow<PasteModel>) {
        self.init(
            id: row[\.$id],
            owner: row[\.$owner],
            name: row[\.$name],
            content: row[\.$content],
            listed: row[\.$listed]
        )
    }
    
    public init?(rawValue: String) {
        let split = rawValue.split(separator: Self.separator)
        guard split.count > 1 else {
            return nil
        }
        self.id = rawValue
        self.owner = String(split[0])
        self.name = String(split[1])
        self.content = ""
        self.listed = true
    }
    
    public init(id: String? = nil, owner: AddressName, name: String, content: String? = nil, listed: Bool = true) {
        self.id = id ?? [owner, name].joined(separator: Self.separator)
        self.owner = owner
        self.name = name
        self.content = content ?? ""
        self.listed = listed
    }
}

public struct PURLModel: BlackbirdModel, Identifiable, RawRepresentable, Codable, Sendable {
    static var separator: String { "{PURL}" }
    
    public var rawValue: String {
        [owner, name].joined(separator: Self.separator)
    }
    
    @BlackbirdColumn
    public var id: String
    @BlackbirdColumn
    public var owner: AddressName
    @BlackbirdColumn
    public var name: String
    @BlackbirdColumn
    public var content: String
    @BlackbirdColumn
    public var listed: Bool
    
    var url: URL? {
        URL(string: content)
    }
    
    enum CodingKeys: String, BlackbirdCodingKey {
        case id
        case owner
        case name
        case content
        case listed
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        owner = try container.decode(AddressName.self, forKey: .owner)
        name = try container.decode(String.self, forKey: .name)
        content = try container.decode(String.self, forKey: .content)
        listed = try container.decode(Bool.self, forKey: .listed)
    }
    
    public init(_ row: Blackbird.ModelRow<PURLModel>) {
        self.init(
            id: row[\.$id],
            owner: row[\.$owner],
            name: row[\.$name],
            content: row[\.$content],
            listed: row[\.$listed]
        )
    }
    
    public init?(rawValue: String) {
        let split = rawValue.split(separator: Self.separator)
        guard split.count > 1 else {
            return nil
        }
        self.id = rawValue
        self.owner = String(split[0])
        self.name = String(split[1])
        self.content = ""
        self.listed = true
    }
    
    public init(id: String? = nil, owner: AddressName, name: String, content: String? = nil, listed: Bool = true) {
        self.id = id ?? [owner, name].joined(separator: Self.separator)
        self.owner = owner
        self.name = name
        self.content = content ?? ""
        self.listed = listed
    }
}

public struct NowListing: BlackbirdModel, Identifiable, Sendable {
    var owner: AddressName { id }
    @BlackbirdColumn
    public var id: AddressName
    @BlackbirdColumn
    var url: String
    @BlackbirdColumn
    var updated: Date
    
    enum CodingKeys: String, BlackbirdCodingKey {
        case id
        case url
        case updated
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._id = try container.decode(BlackbirdColumn<AddressName>.self, forKey: .id)
        self._url = try container.decode(BlackbirdColumn<String>.self, forKey: .url)
        self._updated = try container.decode(BlackbirdColumn<Date>.self, forKey: .updated)
    }
    
    public init(_ row: Blackbird.ModelRow<NowListing>) {
        self.init(owner: row[\.$id], url: row[\.$url], updated: row[\.$updated])
    }
    
    public init(owner: AddressName, url: String, updated: Date) {
        self.id = owner
        self.url = url
        self.updated = updated
    }
}

public struct AddressModel: BlackbirdModel, Identifiable, RawRepresentable, Codable, Sendable {
    public init?(rawValue: String) {
        self = AddressModel(name: rawValue)
    }
    
    public var rawValue: String { id }
    
    @BlackbirdColumn
    public var id: AddressName
    @BlackbirdColumn
    var url: URL?
    @BlackbirdColumn
    var registered: Date?
    
    enum CodingKeys: String, BlackbirdCodingKey {
        case id
        case url
        case registered
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(AddressName.self, forKey: .id)
        url = try container.decodeIfPresent(URL.self, forKey: .url)
        registered = try container.decodeIfPresent(Date.self, forKey: .registered)
    }
    
    public init(_ row: Blackbird.ModelRow<AddressModel>) {
        self = .init(
            name: row[\.$id],
            url: row[\.$url],
            registered: row[\.$registered]
        )
    }
    
    public init(name: AddressName, url: URL? = nil, registered: Date? = nil) {
        self.id = name
        self.url = url
        self.registered = registered
    }
}

public struct StatusModel: BlackbirdModel, Identifiable, Sendable {
    
    @BlackbirdColumn
    public var id: String
    @BlackbirdColumn
    var address: AddressName
    @BlackbirdColumn
    var posted: Date
    
    @BlackbirdColumn
    var status: String
    
    @BlackbirdColumn
    var emoji: String?
    @BlackbirdColumn
    var linkText: String?
    @BlackbirdColumn
    var link: URL?
    
    enum CodingKeys: String, BlackbirdCodingKey {
        case id
        case address
        case posted
        case status
        case emoji
        case linkText
        case link
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._id = try container.decode(BlackbirdColumn<String>.self, forKey: .id)
        self._address = try container.decode(BlackbirdColumn<AddressName>.self, forKey: .address)
        self._posted = try container.decode(BlackbirdColumn<Date>.self, forKey: .posted)
        self._status = try container.decode(BlackbirdColumn<String>.self, forKey: .status)
        self._emoji = try container.decode(BlackbirdColumn<String?>.self, forKey: .emoji)
        self._linkText = try container.decode(BlackbirdColumn<String?>.self, forKey: .linkText)
        self._link = try container.decode(BlackbirdColumn<URL?>.self, forKey: .link)
    }
    
    public init(_ row: Blackbird.ModelRow<StatusModel>) {
        self.init(
            id: row[\.$id],
            address: row[\.$address],
            posted: row[\.$posted],
            status: row[\.$status],
            emoji: row[\.$emoji],
            linkText: row[\.$linkText],
            link: row[\.$link]
        )
    }
    
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
    
    var webLinks: [SharePacket] {
        func extractImageNamesAndURLs(from markdown: String) -> [(name: String, url: URL)] {
            var results = [(name: String, url: URL)]()
            
            do {
                let markdownRegex = try NSRegularExpression(pattern: "\\[(.*?)\\]\\(([^)]+)\\)", options: [])
                let nsString = NSString(string: markdown)
                var matches = markdownRegex.matches(in: markdown, options: [], range: NSRange(location: 0, length: nsString.length))
                
                for set in matches.enumerated() {
                    let match = set.element
                    guard match.numberOfRanges == 3 else { continue }
                    let nameRange = match.range(at: 1)
                    let urlRange = match.range(at: 2)
                    let matchingName = nsString.substring(with: nameRange)
                    let name: String = matchingName
                    let urlString = nsString.substring(with: urlRange)
                    guard let url = URL(string: urlString) else {
                        continue
                    }
                    results.append((name, url))
                }
                
                let dataDetector: NSDataDetector = try .init(types: NSTextCheckingResult.CheckingType.link.rawValue)
                matches = dataDetector.matches(in: markdown, range: NSMakeRange(0, nsString.length))
                matches.forEach({ match in
                    let matchString = nsString.substring(with: match.range)
                    guard let urlMatch = URL(string: matchString), !results.contains(where: { $0.url == urlMatch }) else {
                        return
                    }
                    results.append(("", urlMatch))
                })
            } catch {
                print("Error while processing regex: \(error)")
            }
            
            return results
        }
        return extractImageNamesAndURLs(from: status).map({ SharePacket(name: $0.name, content: $0.url) })
    }
    
    var imageLinks: [SharePacket] {
        func extractImageNamesAndURLs(from markdown: String) -> [(name: String, url: URL)] {
            var results = [(name: String, url: URL)]()
            
            do {
                let regex = try NSRegularExpression(pattern: "!\\[(.*?)\\]\\(([^)]+)\\)", options: [])
                let nsString = NSString(string: markdown)
                let matches = regex.matches(in: markdown, options: [], range: NSRange(location: 0, length: nsString.length))
                
                for set in matches.enumerated() {
                    let match = set.element
                    guard match.numberOfRanges == 3 else { continue }
                    let nameRange = match.range(at: 1)
                    let urlRange = match.range(at: 2)
                    let matchingName = nsString.substring(with: nameRange)
                    let name: String
                    if matchingName.isEmpty {
                        name = "Image \(set.offset + 1)"
                    } else {
                        name = matchingName
                    }
                    let urlString = nsString.substring(with: urlRange)
                    guard let url = URL(string: urlString) else {
                        continue
                    }
                    results.append((name, url))
                }
            } catch {
                print("Error while processing regex: \(error)")
            }
            
            return results
        }
        return extractImageNamesAndURLs(from: status).map({ SharePacket(name: $0.name, content: $0.url) })
    }
    
    var linkedItems: [SharePacket] {
        webLinks.filter({ !imageLinks.contains($0) })
    }
}

public struct GroupStatusLogModel: Sendable {
    let displayTitle: String?
    let statuses: [StatusModel]
}

public struct AddressBioModel: Sendable {
    let address: AddressName
    let bio: String?
    
    public init(address: AddressName, bio: String?) {
        self.address = address
        self.bio = bio
    }
}
