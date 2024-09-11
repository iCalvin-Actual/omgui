//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import AuthenticationServices
import Blackbird
import Combine
import SwiftUI
import Foundation

class DataFetcher: Request {
    var summaryString: String? {
        "Loading"
    }
}

class ListFetcher<T: Listable>: Request {
    static var isModelBacked: Bool {
        T.self is any BlackbirdListable.Type
    }
    
    @Published
    var results: [T] = []
    
    var items: Int { results.count }
    var title: String { "" }
    
    let limit: Int
    var nextPage: Int? = ListFetcher<T>.isModelBacked ? 0 : nil
    
    var filters: [FilterOption] {
        didSet {
            results = []
            nextPage = ListFetcher<T>.isModelBacked ? 0 : nil
        }
    }
    var sort: Sort {
        didSet {
            results = []
            nextPage = ListFetcher<T>.isModelBacked ? 0 : nil
        }
    }
    
    init(items: [T] = [], interface: DataInterface, limit: Int = 42, filters: [FilterOption] = .everyone, sort: Sort = T.defaultSort, automation: AutomationPreferences = .init()) {
        self.results = items
        self.limit = limit
        self.filters = filters
        self.sort = sort
        super.init(interface: interface, automation: automation)
        self.loaded = items.isEmpty
    }
    
    var summaryString: String? {
        "Loading"
    }
    
    override func updateIfNeeded(forceReload: Bool = false) async {
        guard forceReload || (loading && requestNeeded) else {
            return
        }
        nextPage = Self.isModelBacked ? 0 : nil
        await perform()
    }
    
    var hasContent: Bool {
        !results.isEmpty
    }
    
    override var noContent: Bool {
        loaded && results.isEmpty && nextPage == nil
    }
    
    @MainActor
    func fetchNextPageIfNeeded() {
    }
}

class DataBackedListDataFetcher<T: Listable>: ListFetcher<T> {
    
    init(items: [T] = [], interface: DataInterface, automation: AutomationPreferences = .init()) {
        
        super.init(items: items, interface: interface, automation: automation)
        
        self.results = items
        self.loaded = items.isEmpty
    }
    
    override var summaryString: String? {
        let supe = super.summaryString
        guard supe == nil else {
            return supe
        }
        return "\(items)"
    }
}

class AccountInfoDataFetcher: DataFetcher {
    private var name: String
    private var credential: String
    
    @Published
    var accountName: String?
    
    override var requestNeeded: Bool {
        accountName == nil
    }
    
    init(address: AddressName, interface: DataInterface, credential: APICredential) {
        self.name = address
        self.credential = credential
        super.init(interface: interface)
    }
    
    func configure(_ name: AddressName, credential: APICredential) {
        self.name = name
        self.credential = credential
        super.configure()
    }
    
    override func throwingRequest() async throws {
        let address = name
        let credential = credential
        let info = try await interface.fetchAccountInfo(address, credential: credential)
        self.accountName = info?.name
        await self.fetchFinished()
    }
    
    override var noContent: Bool {
        !loading && name.isEmpty
    }
}

class NamedItemDataFetcher<N: NamedDraftable>: DataFetcher {
    let addressName: AddressName
    let title: String
    let credential: APICredential?
    
    @Published
    var model: N?
    
    var draftPoster: NamedDraftPoster<N>? {
        return nil
    }
    
    override var requestNeeded: Bool {
        model == nil
    }
    
    init(name: AddressName, title: String, interface: DataInterface, credential: APICredential? = nil) {
        self.addressName = name
        self.title = title
        self.credential = credential
        super.init(interface: interface)
    }
    
    override var noContent: Bool {
        !loading && model == nil
    }
    
    private func handlePosted(_ model: N) {
        self.model = model
    }
    
    func deleteIfPossible() async throws {
        // override
    }
}
