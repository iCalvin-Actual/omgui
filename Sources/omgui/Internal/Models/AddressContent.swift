//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

enum AddressContent: String, Identifiable, Codable {
    var id: String { rawValue }
    
    case profile
    case now
    case purl
    case pastebin
    case statuslog
    
    var displayString: String {
        switch self {
        case .profile:
            return "Profile"
        case .now:
            return "Now"
        case .purl:
            return "PURLs"
        case .pastebin:
            return "PasteBin"
        case .statuslog:
            return "StatusLog"
        }
    }
    var icon: String {
        switch self {
        case .profile:
            return "person.circle"
        case .now:
            return "clock"
        case .purl:
            return "link"
        case .pastebin:
            return "list.clipboard"
        case .statuslog:
            return "bubble.left"
        }
    }
    
    func externalUrlString(for name: AddressName) -> String {
        switch self {
        case .profile:
            return "\(name).omg.lol"
        case .now:
            return "\(name).omg.lol/now"
        case .purl:
            return "\(name).url.lol"
        case .pastebin:
            return "\(name).paste.lol"
        case .statuslog:
            return "\(name).status.lol"
        }
    }
    
    var color: Color {
        switch self {
        case .profile:
            return .lolYellow
        case .now:
            return .lolGreen
        case .purl:
            return .lolTeal
        case .pastebin:
            return .lolOrange
        case .statuslog:
            return .lolPurple
        }
    }
    
    func destination(_ name: AddressName) -> NavigationDestination {
        switch self {
        case .profile:
            return .webpage(name)
        case .now:
            return .now(name)
        case .purl:
            return .purls(name)
        case .pastebin:
            return .pastebin(name)
        case .statuslog:
            return .statusLog(name)
        }
    }
}
