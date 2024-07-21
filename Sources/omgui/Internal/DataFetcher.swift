//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import AuthenticationServices
import Combine
import SwiftUI
import Foundation

@MainActor
class Request: NSObject, ObservableObject {
    let interface: DataInterface
    
    var loaded: Bool = false
    var loading: Bool = false
    
    var error: Error?
    
    var requests: [AnyCancellable] = []
    
    var noContent: Bool {
        !loading
    }
    
    init(interface: DataInterface) {
        self.interface = interface
        super.init()
    }
    
    func perform() async {
        loading = true
        threadSafeSendUpdate()
        do {
            try await throwingRequest()
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

@MainActor
class DraftPoster<D: SomeDraftable>: Request {
    var address: AddressName
    let credential: APICredential
    
    @Published
    var draft: D.Draft
    var originalDraft: D.Draft?
    
    @Published
    var result: D?
    
    var navigationTitle: String {
        "New"
    }
    
    init(_ address: AddressName, draft: D.Draft, interface: DataInterface, credential: APICredential) {
        self.address = address
        self.credential = credential
        self.draft = draft
        self.originalDraft = draft
        super.init(interface: interface)
    }
    
    func deletePresented() {
        // Override
    }
}

class MDDraftPoster<D: MDDraftable>: DraftPoster<D> {
    
    var mdDraft: D.MDDraftItem
    override var draft: D.Draft {
        get {
            mdDraft as! D.Draft
        }
        set {
            guard let md = newValue as? D.MDDraftItem else {
                return
            }
            mdDraft = md
        }
    }
    
    init?(_ address: AddressName, draftItem: D.MDDraftItem, interface: DataInterface, credential: APICredential) {
        self.mdDraft = draftItem
        super.init(address, draft: draftItem as! D.Draft, interface: interface, credential: credential)
    }
}

class NamedDraftPoster<D: NamedDraftable>: DraftPoster<D> {
    let title: String
    
    let onPost: (D) -> Void
    
    @Published
    var namedDraft: D.NamedDraftItem
    
    override var draft: D.Draft {
        get {
            namedDraft as! D.Draft
        }
        set {
            guard let named = newValue as? D.NamedDraftItem else {
                return
            }
            namedDraft = named
        }
    }
    
    init(
        _ address: AddressName,
        title: String,
        content: String = "",
        interface: DataInterface,
        credential: APICredential,
        onPost: ((D) -> Void)? = nil
    ) {
        self.title = title
        let namedDraft = D.NamedDraftItem(address: address, name: title, content: content, listed: true)
        self.namedDraft = namedDraft
        self.onPost = onPost ?? { _ in }
        super.init(
            address,
            draft: namedDraft as! D.Draft,
            interface: interface,
            credential: credential
        )
    }
    
    override func deletePresented() {
        print("Delete")
    }
}

class ProfileDraftPoster: MDDraftPoster<AddressProfile> {
    override var navigationTitle: String {
        "webpage"
    }
    
    @MainActor
    override func throwingRequest() async throws {
        loading = true
        let draftedAddress = address
        let _ = try await interface.saveAddressProfile(
            draftedAddress,
            content: draft.content,
            credential: credential
        )
        originalDraft = draft
        threadSafeSendUpdate()
    }
}

class NowDraftPoster: MDDraftPoster<NowModel> {
    override var navigationTitle: String {
        "/now"
    }
    
    override func throwingRequest() async throws {
        let draftedAddress = address
        let _ = try await interface.saveAddressNow(
            draftedAddress,
            content: draft.content,
            credential: credential
        )
        originalDraft = draft
        threadSafeSendUpdate()
    }
}

class PasteDraftPoster: NamedDraftPoster<PasteResponse> {
    override var navigationTitle: String {
        if originalDraft == nil {
            return "new paste"
        }
        return "edit"
    }
    
    @MainActor
    override func throwingRequest() async throws {
        let draftedAddress = draft.address
        if let originalName = originalDraft?.name, !originalName.isEmpty, draft.name != originalName {
            try await interface.deletePaste(originalName, from: draftedAddress, credential: credential)
        }
        if let result = try await interface.savePaste(draft, to: draftedAddress, credential: credential) {
            self.result = result
            onPost(result)
        }
        threadSafeSendUpdate()
    }
}

class PURLDraftPoster: NamedDraftPoster<PURLResponse> {
    override var navigationTitle: String {
        if originalDraft == nil {
            return "new PURL"
        }
        return "edit"
    }
    override func throwingRequest() async throws {
        let draftedAddress = draft.address
        if let originalName = originalDraft?.name, !originalName.isEmpty, draft.name != originalName {
            try await interface.deletePURL(originalName, from: draftedAddress, credential: credential)
        }
        if let result = try await interface.savePURL(draft, to: draftedAddress, credential: credential) {
            self.result = result
            onPost(result)
        }
        threadSafeSendUpdate()
    }
    
    var destination: String
    
    init(
        _ address: AddressName = .autoUpdatingAddress,
        title: String = "",
        value: String = "",
        interface: DataInterface,
        credential: APICredential = "",
        onPost: ((PURLResponse) -> Void)? = nil
    ) {
        destination = value
        super.init(
            address,
            title: title,
            content: value,
            interface: interface,
            credential: credential,
            onPost: onPost
        )
    }
    
    func newDraft() -> PURLDraftPoster {
        .init(
            address,
            title: title,
            value: destination,
            interface: interface,
            credential: credential, 
            onPost: onPost
        )
    }
}

@MainActor
class StatusDraftPoster: DraftPoster<StatusResponse> {
    override var navigationTitle: String {
        if originalDraft == nil {
            if address != .autoUpdatingAddress {
                return address.addressDisplayString
            }
            return "new status"
        }
        return "edit"
    }
    
    override func throwingRequest() async throws {
        let draftedAddress = draft.address
        if let posted = try await interface.saveStatusDraft(draft, to: draftedAddress, credential: credential) {
            withAnimation { [weak self] in
                guard let self else {
                    return
                }
                result = posted
                draft = .init(address: address, content: "", emoji: "")
            }
        }
        
        threadSafeSendUpdate()
    }
    
    func fetchCurrentValue() async {
        guard let id = draft.id else {
            loading = false
            return
        }
        let draftedAddress = address
        if let status = try? await interface.fetchAddressStatus(id, from: draftedAddress) {
            draft.emoji = status.emoji ?? ""
            draft.content = status.status
            draft.externalUrl = status.link?.absoluteString
            loading = false
            threadSafeSendUpdate()
        } else {
            loading = false
        }
    }
    
    override func deletePresented() {
        guard let presented = result else {
            return
        }
        let patchDraft = StatusResponse.Draft(model: presented, id: presented.id)
        Task { [weak self] in
            guard let self else { return }
            let draftedAddress = draft.address
            let backup = try await interface.deleteAddressStatus(patchDraft, from: draftedAddress, credential: credential)
            withAnimation {
                if let backup {
                    self.draft = .init(model: backup)
                }
                self.result = nil
            }
        }
    }
}

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
    
    func updateIfNeeded() async {
        guard !loading else {
            return
        }
        await perform()
    }
}

@MainActor
final class AccountAuthDataFetcher: NSObject, ObservableObject, Sendable {
    private var webSession: ASWebAuthenticationSession?
    
    private let client: ClientInfo
    private let interface: DataInterface
    
    var loaded = false
    var loading = false
    
    @Published
    var authToken: String?
    
    private var url: URL?
    private var error: Error?
    private var requests: [AnyCancellable] = []
    
    private let anchor = ASPresentationAnchor()
    
    init(client: ClientInfo, interface: DataInterface) {
        self.client = client
        self.interface = interface
        self.url = interface.authURL()
        super.init()
        
        self.recreateWebSession()
    }
    
    private func recreateWebSession() {
        guard let url = url else {
            return
        }
        self.webSession = ASWebAuthenticationSession(
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
            Task {
                let token = try await self.interface.fetchAccessToken(
                    authCode: code,
                    clientID: client.id,
                    clientSecret: client.secret,
                    redirect: client.redirectUrl
                )
                self.authToken = token
            }
        }
        self.webSession?.presentationContextProvider = self
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

@MainActor
class ListDataFetcher<T: Listable>: DataFetcher, Observable {
    
    var listItems: [T] = []
    
    var title: String { "" }
    
    init(items: [T] = [], interface: DataInterface) {
        self.listItems = items
        super.init(interface: interface)
        self.loaded = items.isEmpty
    }
    
    override var noContent: Bool {
        (!loaded && !loading) && listItems.isEmpty
    }
    
    override var summaryString: String? {
        let supe = super.summaryString
        guard supe == nil else {
            return supe
        }
        return "\(items)"
    }
    
    var items: Int { listItems.count }
}

class StatusDataFetcher: DataFetcher {
    let address: AddressName
    let id: String
    
    var status: StatusResponse?
    
    var linkFetchers: [URLContentDataFetcher] = []
    
    init(id: String, from address: String, interface: DataInterface) {
        self.address = address
        self.id = id
        super.init(interface: interface)
    }
    
    override func throwingRequest() async throws {
        status = try await interface.fetchAddressStatus(id, from: address)
        status?.webLinks.forEach { link in
            linkFetchers.append(.init(url: link.content, interface: interface))
        }
        fetchFinished()
    }
    
    func fetcher(for url: URL) -> URLContentDataFetcher? {
        linkFetchers.first(where: { $0.url == url })
    }
}

@MainActor
class URLContentDataFetcher: DataFetcher {
    let url: URL
    
    @Published
    var html: String?
    
    init(url: URL, html: String? = nil, interface: DataInterface) {
        self.url = url
        self.html = html
        super.init(interface: interface)
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
