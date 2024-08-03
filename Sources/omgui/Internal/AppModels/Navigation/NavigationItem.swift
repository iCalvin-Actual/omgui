//
//  NavigationItem.swift
//  
//
//  Created by Calvin Chestnut on 3/10/23.
//

import Foundation


enum NavigationItem: Codable, Hashable, Identifiable, RawRepresentable {
    var id: String { rawValue }
    
    case account
    case blocked
    case community
    case nowGarden
    case search
    
    case newPaste
    case newPURL
    case newStatus
    
    case following      (_ address: AddressName)
    case pinnedAddress  (_ address: AddressName)
    
    var rawValue: String {
        switch self {
        case .account:                  return "account"
        case .blocked:                  return "blocked"
        case .community:                return "community"
        case .nowGarden:                return "garden"
        case .search:                   return "search"
        
        case .newStatus:                return "new status"
        case .newPURL:                  return "new PURL"
        case .newPaste:                 return "new paste"
            
        case .following(let address):   return "following.\(address)"
        case .pinnedAddress(let address):
                                        return "pinned.\(address)"
        }
    }
    
    init?(rawValue: String) {
        let splitString = rawValue.components(separatedBy: ".")
        switch splitString.first {
        case "account":     self = .account
        case "blocked":     self = .blocked
        case "community":   self = .community
        case "garden":      self = .nowGarden
        case "search":      self = .search
            
        case "new status":
            self = .newStatus
        case "new PURL":
            self = .newPURL
        case "new paste":
            self = .newPaste
            
        case "following":
            guard splitString.count > 1 else {
                self = .following(.autoUpdatingAddress)
                return
            }
            self = .following(splitString[1])
        case "pinned":
            guard splitString.count > 1 else {
                return nil
            }
            self = .pinnedAddress(splitString[1])
            
        default:
            return nil
        }
    }
    
    var displayString: String {
        switch self {
        case .account:      return "/account"
        case .blocked:      return "/blocked"
        case .community:    return "/statuslog"
        case .nowGarden:    return "/nowGarden"
        case .search:       return "/search"
            
        case .newStatus:    return "/new"
        case .newPURL:      return "New PURL"
        case .newPaste:     return "New Paste"
            
        case .following(let address):
            return (address == .autoUpdatingAddress ? "" : "\(address.addressDisplayString).") + "following"
        case .pinnedAddress(let address):
            return address.addressDisplayString
        }
    }
    
    var iconName: String {
        switch self {
        case .account:
            return "at"
        case .search:
            return "magnifyingglass"
        case .nowGarden:
            return "camera.macro"
        case .community:
            return "globe"
        case .following:
            return "person.2"
        case .pinnedAddress:
            return "pin"
        case .blocked:
            return "hand.raised"
        case .newStatus, .newPURL, .newPaste:
            return "pencil.and.scribble"
        }
    }
    
    var destination: NavigationDestination {
        switch self {
        case .account:
            return .account
        case .search:
            return .directory
        case .nowGarden:
            return .nowGarden
        case .community:
            return .community
        case .following(let address):
            return .following(address)
        case .pinnedAddress(let name):
            return .address(name)
        case .blocked:
            return .blocked
        case .newStatus:
            return .editStatus(.autoUpdatingAddress, id: "")
        default:
            return .account
        }
    }
}
