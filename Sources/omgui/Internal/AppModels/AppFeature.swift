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
    case purl
    case weblog
    
    var displayName: String {
        switch self {
        case .service:
            return "omg.lol"
        case .status:
            return "StatusLog"
        case .now:
            return "Now Page"
        case .paste:
            return "PasteBin"
        case .purl:
            return "PURLs"
        case .weblog:
            return "Weblog"
        }
    }
}
