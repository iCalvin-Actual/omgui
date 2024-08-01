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
        Task {
            try await fetchModels()
            try await fetchRemote()
            try await fetchModels()
            
            fetchFinished()
        }
    }
    
    func fetchModels() async throws {
    }
    
    func fetchRemote() async throws {
    }
}

class ModelBackedDataFetcher<M: BlackbirdModel>: BackedDataFetcher {
    @Published
    var result: M?
    
    override var noContent: Bool {
        !loading && result != nil
    }
}

typealias ModelBackedListable = BlackbirdModel & Listable

class ModelBackedListDataFetcher<M: ModelBackedListable>: BackedDataFetcher {
    var results: [M] = []
    var title: String { "" }
    var items: Int { results.count }
    
    override var noContent: Bool {
        !loading && !results.isEmpty
    }
}
