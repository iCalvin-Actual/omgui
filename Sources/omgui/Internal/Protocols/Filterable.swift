//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Blackbird
import Foundation

enum FilterOption: Equatable, RawRepresentable {
    var rawValue: String {
        switch self {
        case .recent(let interval):
            return "interval.\(interval)"
        case .query(let query):
            return "query.\(query)"
        case .from(let address):
            return "from.\(address)"
        case .fromOneOf(let addresses):
            return "fromOne.\(addresses.joined(separator: "."))"
        case .none:
            return ""
        case .notBlocked:
            return "notBlocked"
        case .mine:
            return "mine"
        case .following:
            return "following"
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
        case "from":
            guard splitString.count > 1 else {
                return nil
            }
            let joined = splitString.dropFirst().joined(separator: ".")
            self = .from(joined)
        case "fromOne":
            guard splitString.count > 1 else {
                return nil
            }
            let joined = Array(splitString.dropFirst())
            self = .fromOneOf(joined)
        case "notBlocked":
            self = .notBlocked
        case "mine":
            self = .mine
        case "following":
            self = .following
        case "":
            self = .none
        default:
            return nil
        }
    }
    
    case none
    case mine
    case following
    case notBlocked
    case from(AddressName)
    case fromOneOf([AddressName])
    case recent(TimeInterval)
    case query(String)
}

extension Array<FilterOption> {
    static let none: Self               = []
    static let everyone: Self           = [.notBlocked]
    static let today: Self              = [.recent(86400), .notBlocked]
    static let thisWeek: Self           = [.recent(604800), .notBlocked]
    static let followed: Self           = [.following, .notBlocked]
    static let followedToday: Self      = .followed + .today
    static let followedThisWeek: Self   = .followed + .thisWeek
}

protocol Filterable {
    var addressName: AddressName { get }
    var filterDate: Date? { get }
    
    @MainActor
    func include(with filter: FilterOption, in scene: SceneModel) -> Bool
}

@MainActor
extension Filterable {
    func include(with filters: [FilterOption], in scene: SceneModel) -> Bool {
        for filter in filters {
            if !include(with: filter, in: scene) {
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
    func include(with filter: FilterOption, in scene: SceneModel) -> Bool {
        switch filter {
        case .none:
            return true
//        case .following:
//            guard !addressBook.following.contains(addressName) else {
//                return false
//            }
        case .notBlocked:
            // Check if address is blocked
            if scene.addressBook.isBlocked(addressName) {
                return false
            }
        case .from(let address):
            return addressName == address
        case .fromOneOf(let addresses):
            return addresses.contains(addressName)
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
            return scene.addressBook.myAddresses.contains(addressName)
        case .following:
            return scene.addressBook.following.contains(addressName)
        }
        return true
    }
}

extension Array<FilterOption> {
    @MainActor
    func applyFilters<T: Filterable>(to inputModels: [T], in scene: SceneModel) -> [T] {
        inputModels
            .filter({ $0.include(with: self, in: scene) })
    }
}

extension Array<FilterOption> {
    func asQuery<M: ModelBackedListable>(matchingAgainst addressBook: AddressBook) -> BlackbirdModelColumnExpression<M>? {
        let filters: [BlackbirdModelColumnExpression<M>] = compactMap({ $0.asQuery(addressBook) })
        if filters.count > 1 {
            return .combining(filters)
        } else {
            return filters.first
        }
    }
}

extension FilterOption {
    func asQuery<M: ModelBackedListable>(_ adderessBook: AddressBook) -> BlackbirdModelColumnExpression<M>? {
        switch self {
        case .mine:
            return BlackbirdModelColumnExpression<M>
                .valueIn(M.ownerKey, adderessBook.myAddresses)
        case .following:
            return .valueIn(M.ownerKey, adderessBook.following)
        case .notBlocked:
            return .valueNotIn(M.ownerKey, adderessBook.appliedBlocked)
        case .from(let address):
            return .equals(M.ownerKey, address)
        case .fromOneOf(let addresses):
            return .valueIn(M.ownerKey, addresses)
        case .recent(let interval):
            return .greaterThanOrEqual(M.dateKey, Date(timeIntervalSinceNow: -interval))
        case .query(let queryString):
            return .oneOf(M.fullTextSearchableColumns.compactMap({
                if case .text = $0.value {
                    return .like($0.key, "%\(queryString)%")
                }
                return nil
            }))
        default:
            return nil
        }
    }
}
