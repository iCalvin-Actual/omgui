//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/13/23.
//

import CoreTransferable
import Foundation

struct SharePacket: Identifiable, Hashable {
    
    var id: String { [name, content.absoluteString].joined() }
    
    let name: String
    let content: URL
}

struct CopyPacket: Identifiable {
    
    var id: String { [name, content].joined() }
    
    let name: String
    let content: String
}

extension Transferable {
    var previewText: String {
        if let url = self as? URL {
            return url.absoluteString
        }
        if let string = self as? String {
            return string
        }
        return ""
    }
}

protocol Sharable {
    var primaryCopy: CopyPacket? { get }
    var copyText: [CopyPacket] { get }
    var primaryURL: SharePacket? { get }
    var shareURLs: [SharePacket] { get }
}

extension Sharable {
    var primaryCopy: CopyPacket? { nil }
    var primaryURL: SharePacket? { nil }
    var moreCopy: [CopyPacket] {
        []
    }
    var shareURLs: [SharePacket] {
        []
    }
}

extension AddressModel: Sharable {
    var primaryCopy: CopyPacket? {
        .init(name: "Name", content: addressName)
    }
    var copyText: [CopyPacket] {
        [
            .init(name: "Webpage", content: "https://\(addressName).omg.lol")
        ]
    }
    
    var primaryURL: SharePacket? {
        guard !addressName.isEmpty, let urlSafeAddress = addressName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return nil
        }
        return .init(name: "Webpage", content: URL(string: "https://\(urlSafeAddress).omg.lol")!)
    }
    
    var shareURLs: [SharePacket] {
        return [
        ]
    }
}

extension NowListing: Sharable {
    var primaryCopy: CopyPacket? {
        .init(name: "/Now URL", content: url)
    }
    var copyText: [CopyPacket] {
        [
        ]
    }
    
    var primaryURL: SharePacket? {
        guard !addressName.isEmpty else {
            return nil
        }
        return .init(name: "/Now page", content: URL(string: url)!)
    }
    var shareURLs: [SharePacket] {
        []
    }
}

extension StatusModel: Sharable {
    var primaryCopy: CopyPacket? {
        .init(name: "Status text", content: status)
    }
    var copyText: [CopyPacket] {
        [
            .init(name: "Emoji", content: displayEmoji),
            .init(name: "URL", content: urlString),
            .init(name: "Address", content: address)
        ]
    }
    
    var primaryURL: SharePacket? {
        return .init(name: "URL", content: URL(string: urlString)!)
    }
    var shareURLs: [SharePacket] {
        [
            .init(name: "StatusLog", content: URL(string: "https://\(address).status.lol")!),
            .init(name: "Profile", content: URL(string: "https://\(address).omg.lol")!),
            .init(name: "Now Page", content: URL(string: "https://\(address).omg.lol/now")!)
        ]
    }
}

extension PURLModel: Sharable {
    private var address: CopyPacket {
        .init(name: "Address", content: owner)
    }
    var primaryCopy: CopyPacket? {
        guard !content.isEmpty else {
            return address
        }
        return .init(name: "Copy URL", content: content)
    }
    var copyText: [CopyPacket] {
        if content.isEmpty {
            return [
                address
            ]
        } else {
            return []
        }
    }
    
    var primaryURL: SharePacket? {
        guard let url = URL(string: content) else {
            return nil
        }
        return .init(name: "URL", content: url)
    }
    var shareURLs: [SharePacket] {
        [
            .init(name: "PURL", content: URL(string: "https://\(owner).url.lol/\(name)")!),
            .init(name: "Profile", content: URL(string: "https://\(owner).omg.lol")!)
        ]
    }
}

extension PasteModel: Sharable {
    private var address: CopyPacket {
        .init(name: "Address", content: owner)
    }
    var primaryCopy: CopyPacket? {
        guard !content.isEmpty else {
            return address
        }
        return .init(name: "Copy Content", content: content)
    }
    var copyText: [CopyPacket] {
        if content.isEmpty {
            return [
                .init(name: "Address", content: owner)
            ]
        } else {
            return []
        }
    }
    
    var primaryURL: SharePacket? {
        guard let url = URL(string: "https://\(addressName).paste.lol/\(name)") else {
            return nil
        }
        return .init(name: "Paste URL", content: url)
    }
    var shareURLs: [SharePacket] {
        [
            primaryURL
        ]
        .compactMap({ $0 })
    }
}
