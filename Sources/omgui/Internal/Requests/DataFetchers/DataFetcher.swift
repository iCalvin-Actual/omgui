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
    static var nextPage: Int? {
        Self.isModelBacked ? 0 : nil
    }
    
    @Published
    var results: [T] = []
    
    var items: Int { results.count }
    var title: String { "" }
    
    let limit: Int
    var nextPage: Int? = ListFetcher<T>.nextPage
    
    var filters: [FilterOption] {
        didSet {
            results = []
            nextPage = Self.nextPage
        }
    }
    var sort: Sort {
        didSet {
            results = []
            nextPage = Self.nextPage
        }
    }
    
    init(items: [T] = [], interface: DataInterface, limit: Int = 42, filters: [FilterOption] = .everyone, sort: Sort = T.defaultSort, automation: AutomationPreferences = .init()) {
        self.results = items
        self.limit = limit
        self.filters = filters
        self.sort = sort
        super.init(interface: interface, automation: automation)
        self.loaded = items.isEmpty ? nil : .init()
    }
    
    var summaryString: String? {
        "Loading"
    }
    
    override func updateIfNeeded(forceReload: Bool = false) async {
        guard !loading else {
            return
        }
        guard forceReload || requestNeeded else {
            print("Not performing on \(self)")
            return
        }
        print("Performing on \(self)")
        nextPage = Self.nextPage
        await perform()
    }
    
    var hasContent: Bool {
        !results.isEmpty
    }
    
    var noContent: Bool {
        guard !loading, loaded != nil else {
            return false
        }
        return results.isEmpty
    }
    
    @MainActor
    func fetchNextPageIfNeeded() {
    }
}

class DataBackedListDataFetcher<T: Listable>: ListFetcher<T> {
    
    init(items: [T] = [], interface: DataInterface, automation: AutomationPreferences = .init()) {
        
        super.init(items: items, interface: interface, automation: automation)
        
        self.results = items
        self.loaded = items.isEmpty ? nil : .init()
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
    @Published
    var accountCreated: Date?
    
    override var requestNeeded: Bool {
        accountName == nil && super.requestNeeded
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
        self.accountCreated = info?.created
    }
    
    var noContent: Bool {
        guard !loading else {
            return false
        }
        return loaded != nil && name.isEmpty
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
    
    var noContent: Bool {
        guard !loading else {
            return false
        }
        return loaded != nil && model == nil
    }
    
    private func handlePosted(_ model: N) {
        self.model = model
    }
    
    func deleteIfPossible() async throws {
        // override
    }
}
