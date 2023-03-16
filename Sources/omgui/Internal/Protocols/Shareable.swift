//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/13/23.
//

import CoreTransferable
import Foundation

struct SharePacket<T: Transferable>: Identifiable {
    
    var id: String { [name, content.previewText].joined() }
    
    let name: String
    let content: T
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
    var copyText: [SharePacket<String>] { get }
    var shareURLs: [SharePacket<URL>] { get }
    var shareText: [SharePacket<String>] { get }
    var shareData: [SharePacket<Data>] { get }
}

extension Sharable {
    var copyText: [SharePacket<String>] {
        []
    }
    var shareURLs: [SharePacket<URL>] {
        []
    }
    var shareText: [SharePacket<String>] {
        []
    }
    var shareData: [SharePacket<Data>] {
        []
    }
    var shareItems: Int {
        shareURLs.count + shareText.count + shareData.count
    }
}

extension AddressModel: Sharable {
    var copyText: [SharePacket<String>] {
        [
            .init(name: "Name", content: addressName)
        ]
    }
    
    var shareURLs: [SharePacket<URL>] {
        [
            .init(name: "Webpage", content: URL(string: "https://\(addressName).omg.lol")!)
        ]
    }
}
