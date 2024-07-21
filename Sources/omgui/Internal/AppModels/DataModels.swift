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
    @Attribute(.unique)
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

@Model
final class AddressBioModel {
    @Attribute(.unique)
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
    @Attribute(.unique)
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
final class AddressNowListingModel {
    @Attribute(.unique)
    var owner: AddressName
    
    var url: String
    var updated: Date
    
    convenience init(_ listing: NowListing) {
        self.init(
            owner: listing.owner,
            url: listing.url,
            updated: listing.updated
        )
    }
    
    init(owner: AddressName, url: String, updated: Date) {
        self.owner = owner
        self.url = url
        self.updated = updated
    }
}

@Model
final class AddressNowModel {
    @Attribute(.unique)
    var owner: AddressName
    
    var content: String?
    var html: String?
    var updated: Date?
    var listed: Bool?
    var url: String
    
    convenience init(_ model: NowModel, url: String) {
        self.init(
            owner: model.owner,
            content: model.content,
            html: model.html,
            updated: model.updated,
            listed: model.listed,
            url: url
        )
    }
    
    public init(owner: AddressName, content: String? = nil, html: String? = nil, updated: Date? = nil, listed: Bool? = nil, url: String) {
        self.owner = owner
        self.content = content
        self.html = html
        self.updated = updated
        self.listed = listed
        self.url = url
    }
}

@Model
final class AddressProfileModel {
    @Attribute(.unique)
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
final class AddressPURLModel {
    @Attribute(.unique)
    var id: String
    
    var owner: AddressName
    var title: String
    var destination: String
    
    var listed: Bool
    
    convenience init(_ purl: PURLResponse) {
        self.init(owner: purl.owner, title: purl.value, destination: purl.destination ?? "", listed: purl.listed)
    }
    
    init(owner: AddressName, title: String, destination: String, listed: Bool) {
        self.owner = owner
        self.title = title
        self.destination = destination
        self.listed = listed
        self.id = "\(owner)/\(title)"
    }
    
    var destinationURL: URL? {
        return URL(string: destination)
    }
}

@Model
final class AddressPasteModel {
    @Attribute(.unique)
    var id: String
    var owner: AddressName
    var title: String
    var content: String?
    var listed: Bool
    
    convenience init(_ paste: PasteResponse) {
        self.init(owner: paste.owner, title: paste.name, content: paste.content, listed: paste.listed)
    }
    
    init(owner: AddressName, title: String, content: String? = nil, listed: Bool = true) {
        self.owner = owner
        self.title = title
        self.content = content
        self.listed = listed
        self.id = "\(owner)/\(title)"
    }
}

@Model
final class AddressIconModel {
    @Attribute(.unique)
    var owner: AddressName
    
    var imageData: Data?
    
    init(owner: AddressName, imageData: Data? = nil) {
        self.owner = owner
        self.imageData = imageData
    }
}

@Model
final class AddressInfoModel {
    @Attribute(.unique)
    var owner: AddressName
    
    var url: URL
    var registered: Date
    var following: [AddressName]
    var blocked: [AddressName]
    
    init(owner: AddressName, url: URL, registered: Date, following: [AddressName], blocked: [AddressName]) {
        self.owner = owner
        self.url = url
        self.registered = registered
        self.following = following
        self.blocked = blocked
    }
}

extension DataInterface {
    var swiftModels: [any PersistentModel.Type] {
        [
            AddressBioModel.self,
            StatusModel.self,
            AddressWebpageModel.self,
            AddressProfileModel.self,
            AddressNowModel.self,
            AddressPURLModel.self,
            AddressPasteModel.self,
            AddressInfoModel.self,
            AddressIconModel.self
        ]
    }
}
