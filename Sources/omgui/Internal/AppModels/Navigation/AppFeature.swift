//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import Foundation


enum AppFeature: String {
    case service
    case status
    case now
    case paste
    case photo
    case purl
    case weblog
    
    var displayName: String {
        switch self {
        case .service:
            return "omg.lol"
        case .status:
            return "statuslog"
        case .now:
            return "/now"
        case .paste:
            return "/pastes"
        case .purl:
            return "/purls"
        case .photo:
            return "/pics"
        case .weblog:
            return "/blog"
        }
    }
}
