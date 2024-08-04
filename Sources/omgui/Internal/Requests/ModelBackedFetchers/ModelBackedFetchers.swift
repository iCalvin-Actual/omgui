//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import Blackbird
import Combine

class BackedDataFetcher: Request {
    let db: Blackbird.Database
    
    init(interface: DataInterface, db: Blackbird.Database) {
        self.db = db
        super.init(interface: interface)
    }
    
    override func throwingRequest() async throws {
        defer {
            fetchFinished()
        }
        try await fetchModels()
        
        guard requestNeeded else {
            return
        }
        try await fetchRemote()
        try await fetchModels()
    }
    
    func fetchModels() async throws {
    }
    
    func fetchRemote() async throws {
    }
}

class ModelBackedDataFetcher<M: BlackbirdModel>: BackedDataFetcher {
    @Published
    var result: M?
    
    override var requestNeeded: Bool {
        result == nil
    }
    
    override var noContent: Bool {
        !loading && result != nil
    }
}

typealias ModelBackedListable = BlackbirdListable & Listable

class ModelBackedListDataFetcher<M: ModelBackedListable>: BackedDataFetcher {
    @Published
    var results: [M] = []
    
    let coreLists: CoreLists
    
    let filters: [FilterOption]
    let sort: Sort
    
    var title: String { "" }
    var items: Int { results.count }
    
    let limit: Int
    var nextPage: Int? = 0
    
    init(lists: CoreLists, interface: DataInterface, db: Blackbird.Database, limit: Int = 42, filters: [FilterOption] = [], sort: Sort = M.defaultSort) {
        self.coreLists = lists
        self.limit = limit
        self.filters = filters
        self.sort = sort
        super.init(interface: interface, db: db)
    }
    
    override func fetchModels() async throws {
        guard let nextPage else {
            fetchFinished()
            return
        }
        var nextResults = try await M.read(
            from: db,
            matching: {
                func columnExpression(_ from: FilterOption?) -> BlackbirdModelColumnExpression<M>? {
                    switch from {
                    case .mine:
                        return BlackbirdModelColumnExpression<M>.valueIn(M.ownerKey, coreLists.myAddresses)
                    case .following:
                        return BlackbirdModelColumnExpression<M>.valueIn(M.ownerKey, coreLists.following)
                    case .from(let address):
                        return BlackbirdModelColumnExpression<M>.equals(M.ownerKey, address)
                    case .fromOneOf(let addresses):
                        return BlackbirdModelColumnExpression<M>.valueIn(M.ownerKey, addresses)
                    default:
                        return nil
                    }
                }
                guard !filters.isEmpty else {
                    return nil
                }
                switch filters.count {
                case 0:
                    return nil
                case 1:
                    return columnExpression(filters.first)
                default:
                    print("Concattonate?")
                    return columnExpression(filters.first)
                }
            }(),
            orderBy: {
                switch sort {
                default:
                    return .ascending(M.ownerKey)
                }
            }(),
            limit: limit,
            offset: (nextPage * limit)
        )
        if nextResults.count == limit {
            self.nextPage = nextPage + 1
        } else if nextResults.count != 0 {
            self.nextPage = nil
        }
        var oldResults = results
        results.enumerated().forEach { (offset, element) in
            if let matchingInNext = nextResults.enumerated().first(where: { $0.element == element }) {
                oldResults.remove(at: offset)
                oldResults.insert(matchingInNext.element, at: offset)
                nextResults.remove(at: matchingInNext.offset)
            }
        }
        results = oldResults + nextResults
        objectWillChange.send()
    }
    
    override var requestNeeded: Bool {
        results.isEmpty || !loaded
    }
    
    override var noContent: Bool {
        !loading && !results.isEmpty
    }
}
