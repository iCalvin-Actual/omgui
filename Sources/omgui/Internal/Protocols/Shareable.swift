//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/13/23.
//

import CoreTransferable
import Foundation

struct SharePacket: Identifiable {
    
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
    var copyText: [CopyPacket] { get }
    var shareURLs: [SharePacket] { get }
}

extension Sharable {
    var copyText: [CopyPacket] {
        []
    }
    var shareURLs: [SharePacket] {
        []
    }
}

extension AddressModel: Sharable {
    var copyText: [CopyPacket] {
        [
            .init(name: "Name", content: addressName)
        ]
    }
    
    var shareURLs: [SharePacket] {
        [
            .init(name: "Webpage", content: URL(string: "https://\(addressName).omg.lol")!)
        ]
    }
}
