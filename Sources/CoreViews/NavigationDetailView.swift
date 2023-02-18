//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 2/11/23.
//

import Foundation

@available(iOS 16.1, *)
enum NavigationDetailView: Codable, Hashable, Identifiable {
    var rawValue: String {
        switch self {
        case .empty:
            return "none"
        case .profile(let address):
            return "profile.\(address)"
        case .now(let address):
            return "now.\(address)"
        }
    }
    var id: String { rawValue }
    init?(rawValue: String) {
        let splitString = rawValue.components(separatedBy: ".")
        switch splitString.first {
        case "none":    self = .empty
        case "profile":
            let splitString = rawValue.components(separatedBy: ".")
            switch splitString.count {
            case 2:
                self = .profile(splitString[1])
            default:
                return nil
            }
        case "now":
            let splitString = rawValue.components(separatedBy: ".")
            switch splitString.count {
            case 2:
                self = .profile(splitString[1])
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    case empty
    case profile(AddressName)
    case now(AddressName)
}
