//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import AuthenticationServices
import Combine
import SwiftData
import SwiftUI
import Foundation

class Request: NSObject, ObservableObject {
    let fetchConstructor: FetchConstructor
    
    var interface: DataInterface { fetchConstructor.interface }
    
    var loaded: Bool = false
    var loading: Bool = false
    
    var error: Error?
    
    var requests: [AnyCancellable] = []
    
    var noContent: Bool {
        !loading
    }
    
    init(fetcher: FetchConstructor) {
        self.fetchConstructor = fetcher
        super.init()
    }
    
    func perform() async {
        loading = true
        threadSafeSendUpdate()
        do {
            try await throwingRequest()
            loading = false
        } catch {
            handle(error)
        }
    }
    
    func throwingRequest() async throws {
    }
    
    func fetchFinished() {
        loaded = true
        loading = false
        threadSafeSendUpdate()
    }
    
    func handle(_ incomingError: Error) {
        loaded = false
        loading = false
        error = incomingError
        threadSafeSendUpdate()
    }
    
    func threadSafeSendUpdate() {
        objectWillChange.send()
    }
}

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
    
    override init(fetcher: FetchConstructor) {
        super.init(fetcher: fetcher)
    }
    
    func updateIfNeeded() async {
        guard !loading else {
            return
        }
        await perform()
    }
}

class URLContentDataFetcher: DataFetcher {
    let url: URL
    
    @Published
    var html: String?
    
    init(url: URL, html: String? = nil, fetcher: FetchConstructor) {
        self.url = url
        self.html = html
        super.init(fetcher: fetcher)
    }
    
    override func throwingRequest() async throws {
        guard url.scheme?.contains("http") ?? false else {
            self.fetchFinished()
            return
        }
        URLSession.shared.dataTaskPublisher(for: url)
          .map(\.data)
          .eraseToAnyPublisher()
          .receive(on: DispatchQueue.main)
          .sink(receiveCompletion: { _ in }) { [weak self] newValue in
              self?.html = String(data: newValue, encoding: .utf8)
              self?.fetchFinished()
          }
          .store(in: &requests)
    }
}

@MainActor
final class AccountAuthDataFetcher: NSObject, ObservableObject, Sendable {
    private var webSession: ASWebAuthenticationSession?
    
    private var sceneModel: SceneModel
    
    private var client: ClientInfo {
        sceneModel.fetchConstructor.client
    }
    private var interface: DataInterface {
        sceneModel.fetchConstructor.interface
    }
    private var url: URL? {
        interface.authURL()
    }
    
    var loaded = false
    var loading = false
    
    private var error: Error?
    private var requests: [AnyCancellable] = []
    
    private let anchor = ASPresentationAnchor()
    
    init(sceneModel: SceneModel) {
        self.sceneModel = sceneModel
        super.init()
        
        self.recreateWebSession()
    }
    
    private func recreateWebSession() {
        guard let url, webSession == nil else {
            return
        }
        webSession = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: client.urlScheme
        ) { (callbackUrl, error) in
            guard let callbackUrl = callbackUrl else {
                if let error = error {
                    print("DEBUG: Error \(error)")
                } else {
                    print("DEBUG: Unknown error")
                }
                return
            }
            let components = URLComponents(url: callbackUrl, resolvingAgainstBaseURL: true)
            
            guard let code = components?.queryItems?.filter ({ $0.name == "code" }).first?.value else {
                return
            }
            let client = self.client
            Task { [weak self] in
                guard let self else { return }
                let token = try await interface.fetchAccessToken(
                    authCode: code,
                    clientID: client.id,
                    clientSecret: client.secret,
                    redirect: client.redirectUrl
                )
                setToken(token)
            }
        }
        self.webSession?.presentationContextProvider = self
    }
    
    func setToken(_ newValue: APICredential?) {
        guard let newValue else {
            return
        }
        sceneModel.login(newValue)
    }
    
    func perform() {
        loading = true
        recreateWebSession()
        webSession?.start()
    }
}

extension AccountAuthDataFetcher: ASWebAuthenticationPresentationContextProviding {
    nonisolated
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        anchor
    }
}

class DataBackedDataFetcher<T: PersistentModel>: DataFetcher {
    let predicate: Predicate<T>?
    let context: ModelContext
    
    @Published
    var results: [T] = []
    
    init(predicate: Predicate<T>?, context: ModelContext, fetcher: FetchConstructor, automation: DataFetcher.AutomationPreferences = .init()) {
        self.predicate = predicate
        self.context = context
        super.init(fetcher: fetcher)
    }
    
    override var noContent: Bool {
        (!loaded && !loading) && results.isEmpty
    }
    
    override func throwingRequest() async throws {
        try await fetchRequest()
        if shouldFetch() {
            try await remoteRequest()
            try await fetchRequest()
        }
    }
    
    // Override for best results
    func shouldFetch() -> Bool {
        results.isEmpty
    }
    
    func fetchRequest() async throws {
        let fetchDescriptor = FetchDescriptor<T>(predicate: predicate)
        self.results = try context.fetch(fetchDescriptor)
    }
    
    func remoteRequest() async throws {
        // Override to implement
    }
}

class DataBackedListDataFetcher<L: Listable & PersistentModel>: DataBackedDataFetcher<L> {
    var listItems: [L] {
        results
    }
    
    var title: String { "" }
    
    override var noContent: Bool {
        (!loaded && !loading) && listItems.isEmpty
    }
    
    var items: Int { listItems.count }
}

class DirectoryFetcher: DataBackedListDataFetcher<AddressNameModel> {
    init(context: ModelContext, fetcher: FetchConstructor) {
        super.init(predicate: nil, context: context, fetcher: fetcher)
    }
    
    override func remoteRequest() async throws {
        try await fetchConstructor.fetchDirectory()
        try await fetchRequest()
    }
}
