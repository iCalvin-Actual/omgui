import SwiftUI

enum FilterOption {
    case following
    case recent(TimeInterval)
    case notBlocked
    case query(String)
}

extension Array<FilterOption> {
    static let none: Self =     []
    static let everyone: Self = [.notBlocked]
    static let today: Self =    [.recent(86400), .notBlocked]
    static let thisWeek: Self = [.recent(604800), .notBlocked]
    static let followed: Self = [.following, .notBlocked]
    static let followedToday: Self = .followed + .today
    static let followedThisWeek: Self = .followed + .thisWeek
}

protocol Filterable {
    var addressName: AddressName { get }
    var filterDate: Date? { get }
    func include(with filter: FilterOption, account: AccountModel) -> Bool
}

extension Filterable { 
    func include(with filters: [FilterOption], account: AccountModel) -> Bool {
        for filter in filters {
            if !include(with: filter, account: account) {
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
    var queryCheckStrings: [String] { get }
    func matches(_ query: String) -> Bool
}

extension QueryFilterable {
    func matches(_ query: String) -> Bool {
        queryCheckStrings.contains(where: { $0.contains(query) })
    }
}

extension Filterable {
    func include(with filter: FilterOption, account: AccountModel) -> Bool {
        switch filter {
        case .following:
            let accountFollowed = account.following.contains(where: { $0 == addressName })
            if !accountFollowed {
                return false
            }
        case .notBlocked:
            // Check if accoutn is blocked
            let accountBlocked = account.blocked.contains(where: { $0 == addressName })
            if accountBlocked {
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
        }
        return true
    }
}

extension AddressModel: QueryFilterable {
    var queryCheckStrings: [String] {
        [addressName]
    }
    
    var addressName: AddressName {
        name
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

extension PURLModel {
    var queryCheckStrings: [String] {
        [addressName, destination, value]
            .compactMap({ $0 })
    }
    
    var addressName: AddressName {
        owner
    }
    
    var filterDate: Date? {
        nil
    }
}

extension PasteModel {
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

extension NowModel {
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

