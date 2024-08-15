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

class ListDataFetcher<T: Listable>: DataFetcher {
    
    @Published
    var results: [T] = []
    
    var title: String { "" }
    
    init(items: [T] = [], interface: DataInterface, automation: AutomationPreferences = .init()) {
        self.results = items
        super.init(interface: interface)
        self.loaded = items.isEmpty
    }
    
    override var noContent: Bool {
        (!loaded && !loading) && results.isEmpty
    }
    
    override var summaryString: String? {
        let supe = super.summaryString
        guard supe == nil else {
            return supe
        }
        return "\(items)"
    }
    
    var items: Int { results.count }
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
        self.fetchFinished()
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
