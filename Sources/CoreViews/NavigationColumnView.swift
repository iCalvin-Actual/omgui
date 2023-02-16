//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 2/11/23.
//

import Foundation

@available(iOS 16.1, *)
enum NavigationColumn: Codable, Hashable, Identifiable, RawRepresentable {
    var id: String { rawValue }
    
    case search
    case garden
    case pinned(AddressName)
    case community
    case following
    case saved(UIDotAppDotLOL.Feature)
    case comingSoon(UIDotAppDotLOL.Feature)
    
    var rawValue: String {
        switch self {
        case .search:                   return "search"
        case .garden:                   return "garden"
        case .pinned(let address):      return "pinned.\(address)"
        case .community:                return "community"
        case .following:                return "following"
        case .saved(let feature):       return "saved.\(feature.rawValue)"
        case .comingSoon(let feature):  return "coming.\(feature.rawValue)"
        }
    }
    
    init?(rawValue: String) {
        let splitString = rawValue.components(separatedBy: ".")
        switch splitString.first {
        case "search":      self = .search
        case "garden":      self = .garden
        case "community":   self = .community
        case "following":   self = .following
        case "pinned":
            guard splitString.count > 1 else {
                return nil
            }
            self = .pinned(splitString[1])
        case "saved":
            guard splitString.count > 1, let feature = UIDotAppDotLOL.Feature(rawValue: splitString[1]) else {
                return nil
            }
            self = .saved(feature)
        case "coming":
            guard splitString.count > 1, let feature = UIDotAppDotLOL.Feature(rawValue: splitString[1]) else {
                return nil
            }
            self = .comingSoon(feature)
        default:
            return nil
        }
    }
}

@available(iOS 16.1, *)
extension NavigationColumn?: RawRepresentable {
    public var rawValue: String { "" }
    public init?(rawValue: String) {
        if rawValue.isEmpty {
            return nil
        }
        self = NavigationColumn(rawValue: rawValue)
    }
}

@available(iOS 16.1, *)
extension NavigationColumn {
    var displayString: String {
        switch self {
        case .comingSoon:
            return "Coming Soon"
        case .community:
            return "Community"
        case .following:
            return "Following"
        case .garden:
            return "Now Garden"
        case .pinned(let address):
            return address.addressDisplayString
        case .saved(let feature):
            switch feature {
            case .status:
                return "Saved"
            default:
                return feature.displayName
            }
        case .search:
            return "Search"
        }
    }
    
    var iconName: String {
        switch self {
        case .search:
            return "magnifyingglass"
        case .garden:
            return "camera.macro"
        case .community:
            return "person.2"
        case .following:
            return "star"
        case .saved(let feature):
            switch feature {
            case .now:
                return "camera.macro"
            case .paste:
                return "doc.text"
            case .purl:
                return "link"
            default:
                return "bookmark"
            }
        case .pinned:
            return "pin"
            
        default:
            return "sparkles"
        }
    }
}
