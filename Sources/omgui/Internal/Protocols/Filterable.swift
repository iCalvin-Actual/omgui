//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Foundation

enum FilterOption: Equatable, RawRepresentable {
    var rawValue: String {
        switch self {
        case .recent(let interval):
            return "interval.\(interval)"
        case .query(let query):
            return "query.\(query)"
        case .none:
            return ""
        case .notBlocked:
            return "notBlocked"
        case .mine:
            return "mine"
        }
    }
    
    init?(rawValue: String) {
        let splitString = rawValue.components(separatedBy: ".")
        switch splitString.first {
        case "interval":
            guard splitString.count > 1 else {
                return nil
            }
            let joined = splitString.dropFirst().joined(separator: ".")
            guard let double = TimeInterval(joined) else {
                return nil
            }
            self = .recent(double)
        case "query":
            guard splitString.count > 1 else {
                return nil
            }
            let joined = splitString.dropFirst().joined(separator: ".")
            self = .query(joined)
        case "notBlocked":
            self = .notBlocked
        case "mine":
            self = .mine
        case "":
            self = .none
        default:
            return nil
        }
    }
    
//    case following
    case recent(TimeInterval)
    case notBlocked
    case query(String)
    case mine
    case none
}

extension Array<FilterOption> {
    static let none: Self               = []
    static let everyone: Self           = [.notBlocked]
    static let today: Self              = [.recent(86400), .notBlocked]
    static let thisWeek: Self           = [.recent(604800), .notBlocked]
//    static let followed: Self           = [.following, .notBlocked]
//    static let followedToday: Self      = .followed + .today
//    static let followedThisWeek: Self   = .followed + .thisWeek
}

protocol Filterable {
    var addressName: AddressName { get }
    var filterDate: Date? { get }
    
    @MainActor
    func include(with filter: FilterOption, addressBook: AddressBook) -> Bool
}

@MainActor
extension Filterable {
    func include(with filters: [FilterOption], addressBook: AddressBook) -> Bool {
        for filter in filters {
            if !include(with: filter, addressBook: addressBook) {
                return false
            }
        }
        return true
    }
}

extension Filterable where Self: DateSortable {
    var filterDate: Date? {
        dateValue
    }
}

protocol QueryFilterable: Filterable {
    
    @MainActor
    var queryCheckStrings: [String] { get }
    
    @MainActor
    func matches(_ query: String) -> Bool
}

extension QueryFilterable {
    
    @MainActor
    func matches(_ query: String) -> Bool {
        queryCheckStrings.contains(where: { $0.lowercased().contains(query.lowercased()) })
    }
}

extension Filterable {
    @MainActor
    func include(with filter: FilterOption, addressBook: AddressBook) -> Bool {
        switch filter {
        case .none:
            return true
//        case .following:
//            guard !addressBook.following.contains(addressName) else {
//                return false
//            }
        case .notBlocked:
            // Check if address is blocked
            if addressBook.isBlocked(addressName) {
                return false
            }
        case .query(let query):
            guard let queryable = self as? QueryFilterable else {
                return false
            }
            if !queryable.matches(query) {
                return false
            }
        case .recent(let interval):
            guard let date = filterDate else {
                return false
            }
            if Date().timeIntervalSince(date) > interval {
                return false
            }
        case .mine:
            return addressBook.myAddresses.contains(addressName)
        }
        return true
    }
}

extension AddressModel: QueryFilterable {
    var queryCheckStrings: [String] {
        [addressName]
    }
    
    var addressName: AddressName {
        id
    }
    
    var filterDate: Date? {
        registered
    }
}

extension StatusModel: QueryFilterable {
    var queryCheckStrings: [String] {
        [addressName, emoji, status]
            .compactMap({ $0 })
    }
    
    var addressName: AddressName {
        address
    }
    
    var filterDate: Date? {
        posted
    }
}

extension PURLModel: QueryFilterable {
    var queryCheckStrings: [String] {
        [addressName, name, content?.absoluteString]
            .compactMap({ $0 })
    }
    
    var addressName: AddressName {
        owner
    }
    
    var filterDate: Date? {
        nil
    }
}

extension PasteModel: QueryFilterable {
    var queryCheckStrings: [String] {
        [addressName, name, content]
            .compactMap({ $0 })
    }
    
    var addressName: AddressName {
        owner
    }
    
    var filterDate: Date? {
        nil
    }
}

extension NowListing: QueryFilterable {
    var queryCheckStrings: [String] {
        [addressName]
    }
    
    var addressName: AddressName {
        owner
    }
    
    var filterDate: Date? {
        updated
    }
}
