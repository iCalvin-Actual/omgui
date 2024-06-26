//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/10/23.
//

import SwiftUI
import Foundation


enum NavigationItem: Codable, Hashable, Identifiable, RawRepresentable {
    var id: String { rawValue }
    
    case account
    case search
    case nowGarden
    case community
    case following
    case followingStatuses
    case followingAddresses
    
    case editProfile
    case editNow
    case myStatuses
    case newStatus
    case myPURLs
    case newPURL
    case myPastes
    case newPaste
    
    case pinnedAddress(_ address: AddressName)
    case blocked
    
    var rawValue: String {
        switch self {
        case .account:                  return "account"
        case .search:                   return "search"
        case .nowGarden:                return "garden"
        case .pinnedAddress(let address):     return "pinned.\(address)"
        case .community:                return "community"
        case .following:                return "following"
        case .followingStatuses:        return "following.statuses"
        case .followingAddresses:       return "following.addresses"
        case .blocked:                  return "blocked"
        case .editProfile:              return "my profile"
        case .editNow:                  return "my now"
        case .myStatuses:               return "my statuses"
        case .newStatus:                return "new status"
        case .myPURLs:                  return "my PURLs"
        case .newPURL:                  return "new PURL"
        case .myPastes:                 return "my pastes"
        case .newPaste:                 return "new paste"
        }
    }
    
    init?(rawValue: String) {
        let splitString = rawValue.components(separatedBy: ".")
        switch splitString.first {
        case "account":     self = .account
        case "search":      self = .search
        case "garden":      self = .nowGarden
        case "community":   self = .community
        case "following":
            guard splitString.count > 1 else {
                self = .following
                return
            }
            switch splitString[1] {
            case "addresses":
                self = .followingAddresses
            case "statuses":
                self = .followingStatuses
            default:
                self = .following
            }
        case "pinned":
            guard splitString.count > 1 else {
                return nil
            }
            self = .pinnedAddress(splitString[1])
        case "blocked":
            self = .blocked
        case "my profile":
            self = .editProfile
        case "my now":
            self = .editNow
        case "my statuses":
            self = .myStatuses
        case "new status":
            self = .newStatus
        case "my purls":
            self = .myPURLs
        case "new PURL":
            self = .newPURL
        case "my pastes":
            self = .myPastes
        case "new paste":
            self = .newPaste
        default:
            return nil
        }
    }
    
    var displayString: String {
        switch self {
        case .account:
            return "Account"
        case .community:
            return "/status.log"
        case .following, .followingStatuses, .followingAddresses:
            return "/following"
        case .nowGarden:
            return "/nowGarden"
        case .pinnedAddress(let address):
            return address.addressDisplayString
        case .search:
            return "/search"
        case .blocked:
            return "/blocked"
        case .editProfile:
            return "/profile"
        case .editNow:
            return "/now"
        case .myStatuses:
            return "/statuses"
        case .newStatus:
            return "/new"
        case .myPURLs:
            return "/purls"
        case .newPURL:
            return "New PURL"
        case .myPastes:
            return "/pastes"
        case .newPaste:
            return "New Paste"
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
        case .following, .followingStatuses, .followingAddresses:
            return "person.2"
        case .pinnedAddress:
            return "pin"
        case .blocked:
            return "hand.raised"
        case .newStatus, .newPURL, .newPaste:
            return "pencil.and.scribble"
        case .editProfile, .editNow, .myStatuses, .myPURLs, .myPastes:
            return "at"
        }
    }
    
    @ViewBuilder
    var sidebarView: some View {
        label
    }
    
    var label: some View {
        Label(title: {
            Text(displayString)
        }) {
            Image(systemName: iconName)
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
        case .following:
            return .following
        case .followingStatuses:
            return .followingStatuses
        case .followingAddresses:
            return .followingAddresses
        case .pinnedAddress(let name):
            return .address(name)
        case .blocked:
            return .blocked
        case .myStatuses:
            return .myStatuses
        case .newStatus:
            return .editStatus(.autoUpdatingAddress, id: "")
        case .myPURLs:
            return .myPURLs
        case .myPastes:
            return .myPastes
        default:
            return .account
        }
    }
}
