//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import Foundation

enum NavigationDestination: Codable, Hashable, Identifiable, RawRepresentable {
    var id: String { rawValue }
    
    case lists
    case directory
    case nowGarden
    case address(_ name: AddressName)
    case community
    case following
    case saved(_ feature: AppFeature)
    case comingSoon(_ feature: AppFeature)
    case account
    case blocked
    case addressFollowing(_ name: AddressName)
    case webpage(_ name: AddressName)
    case now(_ name: AddressName)
    case purls(_ name: AddressName)
    case pastebin(_ name: AddressName)
    case statusLog(_ name: AddressName)
    
    var rawValue: String {
        switch self {
        case .lists:                    return "lists"
        case .directory:                return "directory"
        case .nowGarden:                return "garden"
        case .address(let address):     return "address.\(address)"
        case .community:                return "community"
        case .following:                return "following"
        case .saved(let feature):       return "saved.\(feature.rawValue)"
        case .comingSoon(let feature):  return "coming.\(feature.rawValue)"
        case .account:    return "account"
        case .blocked:                  return "blocked"
        case .addressFollowing(let address): return "following.\(address)"
        case .webpage(let address):     return "webpage.\(address)"
        case .now(let address):         return "now.\(address)"
        case .purls(let address):       return "purls.\(address)"
        case .pastebin(let address):    return "pastes.\(address)"
        case .statusLog(let address):   return "status.\(address)"
        }
    }
    
    init?(rawValue: String) {
        let splitString = rawValue.components(separatedBy: ".")
        switch splitString.first {
        case "lists":       self = .lists
        case "directory":   self = .directory
        case "garden":      self = .nowGarden
        case "community":   self = .community
        case "following":   self = .following
        case "account":
            self = .account
        case "address":
            guard splitString.count > 1 else {
                return nil
            }
            self = .address(splitString[1])
        case "saved":
            guard splitString.count > 1, let feature = AppFeature(rawValue: splitString[1]) else {
                return nil
            }
            self = .saved(feature)
        case "coming":
            guard splitString.count > 1, let feature = AppFeature(rawValue: splitString[1]) else {
                return nil
            }
            self = .comingSoon(feature)
        case "blocked":
            self = .blocked
        case "webpage":
            guard splitString.count > 1 else {
                return nil
            }
            self = .webpage(splitString[1])
        case "now":
            guard splitString.count > 1 else {
                return nil
            }
            self = .now(splitString[1])
        case "pastes":
            guard splitString.count > 1 else {
                return nil
            }
            self = .pastebin(splitString[1])
        case "purls":
            guard splitString.count > 1 else {
                return nil
            }
            self = .purls(splitString[1])
        case "status":
            guard splitString.count > 1 else {
                return nil
            }
            self = .statusLog(splitString[1])
        default:
            return nil
        }
    }
}
