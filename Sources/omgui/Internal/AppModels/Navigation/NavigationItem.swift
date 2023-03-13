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
    
    case search
    case nowGarden
    case community
    case following
    
    case pinnedAddress(_ address: AddressName)
    case account(_ signedIn: Bool)
    case blocked
    
    var rawValue: String {
        switch self {
        case .search:                   return "search"
        case .nowGarden:                return "garden"
        case .pinnedAddress(let address):     return "pinned.\(address)"
        case .community:                return "community"
        case .following:                return "following"
        case .account(let signedIn):    return "account.\(signedIn)"
        case .blocked:                  return "blocked"
        }
    }
    
    init?(rawValue: String) {
        let splitString = rawValue.components(separatedBy: ".")
        switch splitString.first {
        case "search":      self = .search
        case "garden":      self = .nowGarden
        case "community":   self = .community
        case "following":   self = .following
        case "pinned":
            guard splitString.count > 1 else {
                return nil
            }
            self = .pinnedAddress(splitString[1])
        case "account":
            guard splitString.count > 1 else {
                return nil
            }
            self = .account(splitString[1].boolValue)
        case "blocked":
            self = .blocked
        default:
            return nil
        }
    }
    
    var displayString: String {
        switch self {
        case .community:
            return "Community"
        case .following:
            return "Following"
        case .nowGarden:
            return "Now Garden"
        case .pinnedAddress(let address):
            return address.addressDisplayString
        case .search:
            return "Search"
        case .account(let signedIn):
            if !signedIn {
                return "Sign In"
            } else {
                return "Account"
            }
        case .blocked:
            return "Blocked"
        }
    }
    
    var iconName: String {
        switch self {
        case .search:
            return "magnifyingglass"
        case .nowGarden:
            return "camera.macro"
        case .community:
            return "person.2"
        case .following:
            return "star"
        case .pinnedAddress:
            return "pin"
        case .account:
            return "person"
        case .blocked:
            return "hand.raised.circle"
        }
    }
    
    @ViewBuilder
    var sidebarView: some View {
        NavigationLink(value: self) {
            label
        }
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
        case .search:
            return .directory
        case .nowGarden:
            return .nowGarden
        case .community:
            return .community
        case .following:
            return .following
        case .pinnedAddress(let name):
            return .address(name)
        case .account:
            return .account
        case .blocked:
            return .blocked
        }
    }
}
