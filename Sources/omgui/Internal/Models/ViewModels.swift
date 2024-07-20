//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

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

public struct AddressProfile: Sendable {
    let owner: AddressName
    let content: String
    
    public init(owner: AddressName, content: String) {
        self.owner = owner
        self.content = content
    }
}

public struct NowModel: Sendable {
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

public struct PasteResponse: Hashable, Identifiable, RawRepresentable, Codable, Sendable {
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

public struct PURLResponse: Hashable, Identifiable, RawRepresentable, Codable, Sendable {
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
    
    public init(owner: AddressName, value: String, destination: String? = nil, listed: Bool = true) {
        self.owner = owner
        self.destination = destination
        self.value = value
        self.listed = listed
    }
}

public struct NowListing: Hashable, Identifiable, Sendable {
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

public struct AddressModel: Hashable, Identifiable, RawRepresentable, Codable, Sendable {
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

public struct StatusResponse: Hashable, Identifiable, Sendable {
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
    let statuses: [StatusResponse]
}
