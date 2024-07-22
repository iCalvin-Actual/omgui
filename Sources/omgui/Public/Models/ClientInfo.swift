//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Foundation

public struct ClientInfo: Sendable {
    let id: String
    let secret: String
    let urlScheme: String
    let callback: String
    
    public init(id: String, secret: String, scheme: String, callback: String) {
        self.id = id
        self.secret = secret
        self.urlScheme = scheme
        self.callback = callback
    }
    
    var redirectUrl: String { urlScheme + callback}
}

extension ClientInfo {
    static var sample: ClientInfo {
        .init(
            id: "some",
            secret: "some",
            scheme: "http",
            callback: "callback"
        )
    }
}
