//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import Foundation

enum NavigationDestination: Codable, Hashable, Identifiable, RawRepresentable {
    var id: String { rawValue }
    
    case directory
    case nowGarden
    case address(_ name: AddressName)
    case community
    case following
    case followingStatuses
    case followingAddresses
    case saved(_ feature: AppFeature)
    case comingSoon(_ feature: AppFeature)
    case account
    case blocked
    case addressFollowing(_ name: AddressName)
    case webpage(_ name: AddressName)
    case editWebpage(_ name: AddressName)
    case now(_ name: AddressName)
    case editNow(_ name: AddressName)
    case purls(_ name: AddressName)
    case pastebin(_ name: AddressName)
    case statusLog(_ name: AddressName)
    case status(_ name: AddressName, id: String)
    case paste(_ name: AddressName, title: String)
    case purl(_ addressName: AddressName, title: String)
    case editStatus(_ name: AddressName, id: String)
    case editPaste(_ name: AddressName, title: String)
    case editPURL(_ name: AddressName, title: String)
    case myStatuses
    case myPURLs
    case myPastes
    
    var rawValue: String {
        switch self {
        case .directory:                return "directory"
        case .nowGarden:                return "garden"
        case .address(let address):     return "address.\(address)"
        case .community:                return "community"
        case .following:                return "following"
        case .followingStatuses:        return "following.statuses"
        case .followingAddresses:       return "following.addresses"
        case .saved(let feature):       return "saved.\(feature.rawValue)"
        case .comingSoon(let feature):  return "coming.\(feature.rawValue)"
        case .account:                  return "account"
        case .blocked:                  return "blocked"
        case .addressFollowing(let address): return "following.\(address)"
        case .webpage(let address):     return "webpage.\(address)"
        case .editWebpage(let address): return "webpage.\(address).edit"
        case .now(let address):         return "now.\(address)"
        case .editNow(let address):     return "now.\(address).edit"
        case .purls(let address):       return "purls.\(address)"
        case .pastebin(let address):    return "pastes.\(address)"
        case .statusLog(let address):   return "status.\(address)"
        case .status(let address, let id):          return "status.\(address).\(id)"
        case .editStatus(let address, let id):      return "status.\(address).\(id).edit"
        case .paste(let address, let paste):        return "paste.\(address).\(paste)"
        case .purl(let address, let purl):          return "purl.\(address).\(purl)"
        case .editPURL(let address, let purl):      return "purl.\(address).\(purl).edit"
        case .editPaste(let paste, let address):    return "paste.\(address).\(paste).edit"
        case .myStatuses:                           return "myStatuses"
        case .myPURLs:                              return "myPURLs"
        case .myPastes:                             return "myPastes"
        }
    }
    
    init?(rawValue: String) {
        let splitString = rawValue.components(separatedBy: ".")
        switch splitString.first {
        case "directory":   self = .directory
        case "garden":      self = .nowGarden
        case "community":   self = .community
        case "account":     self = .account
        case "following":
            guard splitString.count > 1 else {
                self = .following
                return
            }
            switch splitString[1] {
            case "statuses":
                self = .followingStatuses
            case "addresses":
                self = .followingAddresses
            default:
                self = .following
            }
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
            if splitString.last == "edit" {
                self = .editWebpage(splitString[1])
            } else {
                self = .webpage(splitString[1])
            }
        case "now":
            guard splitString.count > 1 else {
                return nil
            }
            if splitString.last == "edit" {
                self = .editNow(splitString[1])
            } else {
                self = .now(splitString[1])
            }
        case "paste":
            guard splitString.count > 2 else {
                return nil
            }
            let address = splitString[1]
            let title = splitString[2]
            if splitString.last == "edit" {
                self = .editPaste(address, title: title)
            } else {
                self = .paste(address, title: title)
            }
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
        case "purl":
            guard splitString.count > 2 else {
                return nil
            }
            let address = splitString[1]
            let title = splitString[2]
            if splitString.last == "edit" {
                self = .editPURL(address, title: title)
            } else {
                self = .purl(address, title: title)
            }
        case "status":
            switch splitString.count {
            case 0, 1:
                self = .community
            case 2:
                self = .statusLog(splitString[1])
            default:
                if splitString.last == "edit" {
                    self = .editStatus(splitString[1], id: splitString[2])
                } else {
                    self = .status(splitString[1], id: splitString[2])
                }
            }
        case "myStatuses":
            self = .myStatuses
        case "myPURLs":
            self = .myPURLs
        case "myPastes":
            self = .myPastes
        default:
            return nil
        }
    }
}
