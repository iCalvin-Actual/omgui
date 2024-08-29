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
    
    init(interface: DataInterface, db: Blackbird.Database, automation: AutomationPreferences = .init()) {
        self.db = db
        super.init(interface: interface, automation: automation)
    }
    
    override func throwingRequest() async throws {
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
    
    let addressBook: AddressBook?
    
    var filters: [FilterOption] {
        didSet {
            results = []
            nextPage = 0
        }
    }
    var sort: Sort {
        didSet {
            results = []
            nextPage = 0
        }
    }
    
    var title: String { "" }
    var items: Int { results.count }
    
    let limit: Int
    var nextPage: Int? = 0
    
    init(addressBook: AddressBook?, interface: DataInterface, db: Blackbird.Database, limit: Int = 42, filters: [FilterOption] = .everyone, sort: Sort = M.defaultSort, automation: AutomationPreferences = .init()) {
        self.addressBook = addressBook
        self.limit = limit
        self.filters = filters
        self.sort = sort
        super.init(interface: interface, db: db, automation: automation)
    }
    
    override func updateIfNeeded(forceReload: Bool = false) async {
        guard forceReload || (loading && requestNeeded) else {
            return
        }
        nextPage = 0
        await perform()
    }
    
    @MainActor
    override func fetchModels() async throws {
        guard let nextPage, let addressBook else {
            Task {
                await fetchFinished()
            }
            return
        }
        var nextResults = try await M.read(
            from: db,
            matching: filters.asQuery(matchingAgainst: addressBook),
            orderBy: sort.asClause(),
            limit: limit,
            offset: (nextPage * limit)
        )
        var oldResults = nextPage == 0 ? [] : results
        if nextResults.count == limit {
            self.nextPage = nextPage + 1
        } else if nextResults.count != 0 {
            self.nextPage = nil
        }
        if !oldResults.isEmpty {
            results.enumerated().forEach { (offset, element) in
                if let matchingInNext = nextResults.enumerated().first(where: { $0.element == element }) {
                    oldResults.remove(at: offset)
                    oldResults.insert(matchingInNext.element, at: offset)
                    nextResults.remove(at: matchingInNext.offset)
                }
            }
        }
        results = oldResults + nextResults
    }
    
    override var requestNeeded: Bool {
        results.isEmpty || !loaded
    }
    
    override var noContent: Bool {
        !loading && !results.isEmpty
    }
}
