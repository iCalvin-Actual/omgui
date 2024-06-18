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
        default:
            return nil
        }
    }
    
    var displayString: String {
        switch self {
        case .account:
            return "Account"
        case .community:
            return "Community"
        case .following, .followingStatuses, .followingAddresses:
            return "Following"
        case .nowGarden:
            return "Now Garden"
        case .pinnedAddress(let address):
            return address.addressDisplayString
        case .search:
            return "Search"
        case .blocked:
            return "Blocked"
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
        }
    }
}
