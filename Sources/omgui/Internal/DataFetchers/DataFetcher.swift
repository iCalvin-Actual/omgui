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

@MainActor
class DataFetcher: Request {
    struct AutomationPreferences {
        var autoLoad: Bool
        var reloadDuration: TimeInterval?
        
        init(_ autoLoad: Bool = true, reloadDuration: TimeInterval? = nil) {
            self.reloadDuration = reloadDuration
            self.autoLoad = autoLoad
        }
    }
    
    var summaryString: String? {
        "Loading"
    }
    
    init(interface: DataInterface, automation: AutomationPreferences = .init()) {
        super.init(interface: interface)
        if automation.autoLoad {
            Task {
                await perform()
            }
        }
    }
}

@MainActor
class ListDataFetcher<T: Listable>: DataFetcher, Observable {
    
    var results: [T] = []
    
    var title: String { "" }
    
    init(items: [T] = [], interface: DataInterface) {
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
    private let name: String
    private let credential: String
    
    var accountName: String?
    
    init(address: AddressName, interface: DataInterface, credential: APICredential) {
        self.name = address
        self.credential = credential
        super.init(interface: interface)
    }
    
    override func throwingRequest() async throws {
        let info = try await interface.fetchAccountInfo(name, credential: credential)
        self.accountName = info?.name
        self.threadSafeSendUpdate()
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
    
    public func deleteIfPossible() async throws {
        // override
    }
}

class AddressPasteDataFetcher: NamedItemDataFetcher<PasteModel> {
    override var draftPoster: PasteDraftPoster? {
        guard let credential else {
            return super.draftPoster as? PasteDraftPoster
        }
        if let model {
            return .init(
                addressName,
                title: model.name,
                content: model.content ?? "",
                interface: interface,
                credential: credential
            )
        } else {
            return .init(
                addressName,
                title: "",
                interface: interface,
                credential: credential
            )
        }
    }
    
    override func throwingRequest() async throws {
        Task {
            model = try await interface.fetchPaste(title, from: addressName, credential: credential)
            threadSafeSendUpdate()
        }
    }
    
    override func deleteIfPossible() async throws {
        guard let credential else {
            return
        }
        let _ = try await interface.deletePaste(title, from: addressName, credential: credential)
        model = PasteModel(owner: addressName, name: "")
        threadSafeSendUpdate()
    }
}

class AddressPURLDataFetcher: NamedItemDataFetcher<PURLModel> {
    
    @Published
    var purlContent: String?
    
    override var draftPoster: PURLDraftPoster? {
        guard let credential else {
            return super.draftPoster as? PURLDraftPoster
        }
        if let model {
            return PURLDraftPoster(
                addressName,
                title: model.name,
                value: model.content?.absoluteString ?? "",
                interface: interface,
                credential: credential
            )
        } else {
            return .init(
                addressName,
                title: title,
                interface: interface,
                credential: credential
            )
        }
    }
    
    override func throwingRequest() async throws {
        Task {
            if let credential = credential {
                model = try await interface.fetchPURL(title, from: addressName, credential: credential)
            } else {
                let addressPurls = try await interface.fetchAddressPURLs(addressName, credential: nil)
                model = addressPurls.first(where: { $0.name == title })
            }
            purlContent = try await interface.fetchPURLContent(title, from: addressName, credential: credential)
            fetchFinished()
        }
    }
    
    override func deleteIfPossible() async throws {
        guard let credential else {
            return
        }
        let _ = try await interface.deletePURL(title, from: addressName, credential: credential)
        model = PURLModel(owner: addressName, name: "")
        threadSafeSendUpdate()
    }
}
