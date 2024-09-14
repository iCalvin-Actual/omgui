//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import Blackbird
import Combine

class BackedDataFetcher: Request {
    @Published
    var db: Blackbird.Database
    
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
    }
    
    func fetchModels() async throws {
    }
    
    func fetchRemote() async throws {
        try await fetchModels()
    }
}

class ModelBackedDataFetcher<M: BlackbirdModel>: BackedDataFetcher {
    @Published
    var result: M?
    
    override var noContent: Bool {
        !loading && result != nil
    }
}

typealias ModelBackedListable = BlackbirdListable & Listable

class ModelBackedListDataFetcher<T: ModelBackedListable>: ListFetcher<T> {
    
    let addressBook: AddressBook?
    let db: Blackbird.Database
    
    init(addressBook: AddressBook?, interface: DataInterface, db: Blackbird.Database, limit: Int = 42, filters: [FilterOption] = .everyone, sort: Sort = T.defaultSort, automation: AutomationPreferences = .init()) {
        self.addressBook = addressBook
        self.db = db
        super.init(items: [], interface: interface, limit: limit, filters: filters, sort: sort, automation: automation)
    }
    
    @MainActor
    override func throwingRequest() async throws {
        try await fetchModels()
        
        guard requestNeeded else {
            return
        }
        try await fetchRemote()
    }
    
    @MainActor
    override func fetchNextPageIfNeeded() {
        if !loaded {
            Task { [weak self] in
                await self?.updateIfNeeded(forceReload: true)
            }
        } else if !loading {
            Task { [weak self] in
                try? await self?.fetchModels()
            }
        }
    }
    
    // must override
    @MainActor
    func fetchRemote() async throws {
        if nextPage == nil {
            nextPage = ListFetcher<NowListing>.isModelBacked ? 0 : nil
        }
        try await fetchModels()
    }
    
    @MainActor
    func fetchModels() async throws {
        guard let nextPage, let addressBook else {
            Task {
                await fetchFinished()
            }
            return
        }
        var nextResults = try await T.read(
            from: db,
            matching: filters.asQuery(matchingAgainst: addressBook),
            orderBy: sort.asClause(),
            limit: limit,
            offset: (nextPage * limit)
        )
        var oldResults = nextPage == 0 ? [] : results
        if nextResults.count == limit {
            self.nextPage = nextPage + 1
        } else if nextResults.count != 0 || (nextResults + oldResults).count == 0 {
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
}
