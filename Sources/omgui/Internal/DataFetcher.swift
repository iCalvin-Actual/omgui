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
    var originalContent: String
    
    @Published
    var result: D?
    
    var navigationTitle: String {
        "New"
    }
    
    init(_ address: AddressName, draft: D.Draft, interface: DataInterface, credential: APICredential) {
        self.address = address
        self.credential = credential
        self.draft = draft
        self.originalContent = draft.content
        super.init(interface: interface)
        Task {
            await fetchCurrentValue()
        }
    }
    
    func fetchCurrentValue() async {
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
    
    init(_ address: AddressName, title: String, interface: DataInterface, credential: APICredential) {
        self.title = title
        self.namedDraft = D.NamedDraftItem(address: address, name: title, content: "", listed: false)
        let d = namedDraft as! D.Draft
        super.init(address, draft: d, interface: interface, credential: credential)
    }
    
    override func fetchCurrentValue() async {
        loading = false
        threadSafeSendUpdate()
    }
}

class ProfileDraftPoster: MDDraftPoster<AddressProfile> {
    override var navigationTitle: String {
        "webpage"
    }
    
    @MainActor
    override func throwingRequest() async throws {
        loading = true
        let _ = try await interface.saveAddressProfile(
            address,
            content: draft.content,
            credential: credential
        )
        originalContent = draft.content
        threadSafeSendUpdate()
    }
    
    override func fetchCurrentValue() async {
        loading = true
        do {
            if let profile = try await interface.fetchAddressProfile(address, credential: credential) {
                draft.content = profile.content
                originalContent = profile.content
            }
            threadSafeSendUpdate()
        } catch {
            loading = false
        }
    }
}

class NowDraftPoster: MDDraftPoster<NowModel> {
    override var navigationTitle: String {
        "/now"
    }
    
    override func throwingRequest() async throws {
        let _ = try await interface.saveAddressNow(
            address,
            content: draft.content,
            credential: credential
        )
        originalContent = draft.content
        threadSafeSendUpdate()
    }
    
    override func fetchCurrentValue() async {
        do {
            if let now = try await interface.fetchAddressNow(address) {
                let nonNilContent = now.content ?? draft.content
                draft.content = nonNilContent
                originalContent = nonNilContent
            }
            threadSafeSendUpdate()
        } catch {
            loading = false
        }
    }
}

class PasteDraftPoster: NamedDraftPoster<PasteModel> {
    override var navigationTitle: String {
        if originalContent.isEmpty {
            return "new paste"
        }
        return "edit"
    }
    
    override func throwingRequest() async throws {
        let _ = try await interface.savePaste(draft, to: address, credential: credential)
        threadSafeSendUpdate()
    }
    
    override func fetchCurrentValue() async {
        if let paste = try? await interface.fetchPaste(draft.name, from: address, credential: credential), let content = paste.content {
            originalContent = content
            draft.listed = paste.listed
            if !content.isEmpty && draft.content.isEmpty {
                draft.content = content
            }
        }
        await super.fetchCurrentValue()
    }
}

class PURLDraftPoster: NamedDraftPoster<PURLModel> {
    override var navigationTitle: String {
        if originalContent.isEmpty {
            return "new PURL"
        }
        return "edit"
    }
    override func throwingRequest() async throws {
        let _ = try await interface.savePURL(draft, to: address, credential: credential)
        threadSafeSendUpdate()
    }
    
    override func fetchCurrentValue() async {
        if let purl = try? await interface.fetchPURL(draft.name, from: address, credential: credential), let content = purl.destination, !content.isEmpty {
            originalContent = content
            draft.listed = purl.listed
            if draft.content.isEmpty {
                draft.content = content
            }
        }
        await super.fetchCurrentValue()
    }
}

class StatusDraftPoster: DraftPoster<StatusModel> {
    override var navigationTitle: String {
        if originalContent.isEmpty {
            if address != .autoUpdatingAddress {
                return address.addressDisplayString
            }
            return "new status"
        }
        return "edit"
    }
    
    override func throwingRequest() async throws {
        if let posted = try await interface.saveStatusDraft(draft, to: address, credential: credential) {
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
    
    override func fetchCurrentValue() async {
        guard let id = draft.id else {
            loading = false
            return
        }
        if let status = try? await interface.fetchAddressStatus(id, from: address) {
            draft.emoji = status.emoji ?? ""
            draft.content = status.status
            draft.externalUrl = status.link?.absoluteString
            threadSafeSendUpdate()
        } else {
            loading = false
        }
    }
    
    func deletePresented() {
        guard let presented = result else {
            return
        }
        let patchDraft = StatusModel.Draft(model: presented, id: presented.id)
        Task { [weak self] in
            guard let self else { return }
            let backup = try await interface.deleteAddressStatus(patchDraft, from: address, credential: credential)
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
class AddressIconDataFetcher: DataFetcher {
    private var cancellables = Set<AnyCancellable>()

    let address: AddressName
    
    @Published
    var iconData: Data?
    
    init(address: AddressName, interface: DataInterface) {
        self.address = address
        super.init(interface: interface)
    }
    
    override func throwingRequest() async throws {
        guard let url = address.addressIconURL else {
            return
        }
        URLSession.shared.dataTaskPublisher(for: url)
            .map{ $0.data }
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { [weak self] value in
                self?.iconData = value
            }
            .store(in: &cancellables)

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

class AddressDirectoryDataFetcher: ListDataFetcher<AddressModel> {
    override var title: String {
        "omg.lol"
    }
    
    override func throwingRequest() async throws {
        Task {
            let directory = try await interface.fetchAddressDirectory()
            DispatchQueue.main.async {
                self.listItems = directory.map({ AddressModel(name: $0) })
                self.fetchFinished()
            }
        }
    }
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

class AccountAddressDataFetcher: ListDataFetcher<AddressModel> {
    override var title: String {
        "my addresses"
    }
    private let credential: String
    
    init(interface: DataInterface, credential: APICredential) {
        self.credential = credential
        super.init(items: [], interface: interface)
    }
    
    override func throwingRequest() async throws {
        Task {
            self.listItems = try await interface.fetchAccountAddresses(credential).map({ AddressModel(name: $0) })
            self.fetchFinished()
        }
    }
}

class AddressBioDataFetcher: DataFetcher {
    let address: AddressName
    
    var bio: AddressBioModel?
    
    init(address: AddressName, interface: DataInterface) {
        self.address = address
        super.init(interface: interface)
    }
    
    override func throwingRequest() async throws {
        Task {
            let bio = try await interface.fetchAddressBio(address)
            self.bio = bio
            self.threadSafeSendUpdate()
        }
    }
}

class AddressFollowingDataFetcher: ListDataFetcher<AddressModel> {
    let address: AddressName
    let credential: APICredential?
    
    override var title: String {
        "following"
    }
    
    init(address: AddressName, credential: APICredential?, interface: DataInterface) {
        self.address = address
        self.credential = credential
        super.init(interface: interface)
    }
    
    override func throwingRequest() async throws {
        Task {
            guard let content = try await interface.fetchPaste("app.lol.following", from: address, credential: credential)?.content else {
                self.fetchFinished()
                return
            }
            let list = content.components(separatedBy: .newlines).map({ String($0) }).filter({ !$0.isEmpty })
            self.handleItems(list)
        }
    }
    
    private func handleItems(_ addresses: [AddressName]) {
        DispatchQueue.main.async {
            self.listItems = addresses.map({ AddressModel(name: $0) })
            self.fetchFinished()
            self.threadSafeSendUpdate()
        }
    }
    
    func follow(_ toFollow: AddressName, credential: APICredential) {
        let newValue = Array(Set(self.listItems.map({ $0.name }) + [toFollow]))
        let newContent = newValue.joined(separator: "\n")
        let draft = PasteModel.Draft(
            address: address,
            name: "app.lol.following",
            content: newContent,
            listed: true
        )
        Task {
            let _ = try await self.interface.savePaste(draft, to: address, credential: credential)
            self.handleItems(newValue)
        }
    }
    
    func unFollow(_ toRemove: AddressName, credential: APICredential) {
        let newValue = listItems.map({ $0.name }).filter({ $0 != toRemove })
        let newContent = newValue.joined(separator: "\n")
        let draft = PasteModel.Draft(
            address: address,
            name: "app.lol.following",
            content: newContent,
            listed: true
        )
        Task {
            let _ = try await self.interface.savePaste(draft, to: address, credential: credential)
            self.handleItems(newValue)
        }
    }
}

class BlockListDataFetcher: ListDataFetcher<AddressModel> {
    override var title: String {
        "blocked"
    }
    
    let addressBlocklistFetcher: AddressBlockListDataFetcher?
    let globalBlocklistFetcher: AddressBlockListDataFetcher
    let localBloclistFetcher: LocalBlockListDataFetcher
    
    override var loading: Bool {
        get {
            globalBlocklistFetcher.loading || localBloclistFetcher.loading || addressBlocklistFetcher?.loading ?? false
        }
        set { }
    }
    override var loaded: Bool {
        get {
            let stableLoaded = globalBlocklistFetcher.loaded && localBloclistFetcher.loaded
            let localLoaded = addressBlocklistFetcher?.loaded ?? true
            return stableLoaded && localLoaded
        }
        set { }
    }
    
    override var listItems: [AddressModel] {
        get {
            Array(Set((addressBlocklistFetcher?.listItems ?? []) + localBloclistFetcher.listItems))
        }
        set { }
    }
    
    init(
        globalFetcher: AddressBlockListDataFetcher,
        localFetcher: LocalBlockListDataFetcher,
        addressFetcher: AddressBlockListDataFetcher? = nil,
        interface: DataInterface
    ) {
        self.addressBlocklistFetcher = addressFetcher
        self.globalBlocklistFetcher = globalFetcher
        self.localBloclistFetcher = localFetcher
        
        super.init(interface: interface)
        
        globalBlocklistFetcher.objectWillChange.sink { _ in
            self.updateList()
        }.store(in: &requests)
        
        localBloclistFetcher.objectWillChange.sink { _ in
            self.updateList()
        }.store(in: &requests)
        
        addressBlocklistFetcher?.objectWillChange.sink { _ in
            self.updateList()
        }.store(in: &requests)
    }
    
    func updateList() {
        let local = localBloclistFetcher.listItems
        let address = addressBlocklistFetcher?.listItems ?? []
        self.listItems = Array(Set(local + address))
        self.threadSafeSendUpdate()
    }
    
    func block(_ address: AddressName, credential: APICredential?) {
        if addressBlocklistFetcher != nil, let credential = credential {
            addressBlocklistFetcher?.block(address, credential: credential)
        }
        localBloclistFetcher.insert(address)
    }
    
    func insertItems(_ newItems: [AddressModel]) {
        let toAdd = newItems.filter { !listItems.contains($0) }
        self.listItems.append(contentsOf: toAdd)
        self.fetchFinished()
    }
    
    override func perform() async {
        await super.perform()
        await globalBlocklistFetcher.updateIfNeeded()
        await localBloclistFetcher.updateIfNeeded()
        await addressBlocklistFetcher?.updateIfNeeded()
    }
}

class PinnedListDataFetcher: ListDataFetcher<AddressModel> {
    @AppStorage("app.lol.cache.pinned.history", store: .standard)
    private var pinnedAddressesHistory: String = "app"
    var previouslyPinnedAddresses: Set<AddressName> {
        get {
            let split = pinnedAddressesHistory.split(separator: "&&&")
            return Set(split.map({ String($0) }))
        }
        set {
            pinnedAddressesHistory = newValue.sorted().joined(separator: "&&&")
        }
    }
    
    @AppStorage("app.lol.cache.pinned", store: .standard)
    private var currentlyPinnedAddresses: String = "adam&&&app"
    
    var pinnedAddresses: [AddressName] {
        get {
            let split = currentlyPinnedAddresses.split(separator: "&&&")
            return split.map({ String($0) })
        }
        set {
            currentlyPinnedAddresses = Array(Set(newValue)).joined(separator: "&&&")
            Task {
                await self.perform()
            }
        }
    }
    
    override var title: String {
        "pinned"
    }
    
    override func throwingRequest() async throws {
        DispatchQueue.main.async {
            self.listItems = self.pinnedAddresses.map({ AddressModel.init(name: $0) })
            self.fetchFinished()
        }
    }
    
    func isPinned(_ address: AddressName) -> Bool {
        pinnedAddresses.contains(address)
    }
    
    func pin(_ address: AddressName) {
        pinnedAddresses.append(address)
    }
    
    func removePin(_ address: AddressName) {
        pinnedAddresses.removeAll(where: { $0 == address })
    }
}

class LocalBlockListDataFetcher: ListDataFetcher<AddressModel> {
    
    // MARK: No-Account Blocklist
    @AppStorage("app.lol.cache.blocked", store: .standard)
    private var cachedBlockList: String = ""
    var blockedAddresses: [AddressName] {
        get {
            let split = cachedBlockList.split(separator: "&&&")
            return split.map({ String($0) })
        }
        set {
            cachedBlockList = Array(Set(newValue)).joined(separator: "&&&")
            Task {
                await self.perform()
            }
        }
    }
    
    init(interface: DataInterface) {
        super.init(interface: interface)
        self.listItems = blockedAddresses.map({ AddressModel.init(name: $0) })
        
    }
    override var title: String {
        "blocked"
    }
    
    override func throwingRequest() async throws {
        self.listItems = blockedAddresses.map({ AddressModel.init(name: $0) })
        self.fetchFinished()
    }
    
    func remove(_ address: AddressName) {
        blockedAddresses.removeAll(where: { $0 == address })
    }
    
    func insert(_ address: AddressName) {
        blockedAddresses.append(address)
    }
}

class AddressBlockListDataFetcher: ListDataFetcher<AddressModel> {
    let address: AddressName
    let credential: APICredential?
    
    override var title: String {
        "blocked from \(address)"
    }
    
    init(address: AddressName, credential: APICredential? = nil, interface: DataInterface) {
        self.address = address
        self.credential = credential
        super.init(interface: interface)
    }
    
    override func throwingRequest() async throws {
        guard !address.isEmpty else {
            threadSafeSendUpdate()
            return
        }
        let paste = try await interface.fetchPaste("app.lol.blocked", from: address, credential: credential)
        let list = paste?.content?.components(separatedBy: .newlines).map({ String($0) }).filter({ !$0.isEmpty }) ?? []
        self.listItems = list.map({ AddressModel(name: $0) })
        self.fetchFinished()
    }
    
    func block(_ toBlock: AddressName, credential: APICredential) {
        let newValue = Array(Set(self.listItems.map({ $0.name }) + [toBlock]))
        let newContent = newValue.joined(separator: "\n")
        let draft = PasteModel.Draft(
            address: address,
            name: "app.lol.blocked",
            content: newContent,
            listed: false
        )
        Task {
            let _ = try await self.interface.savePaste(draft, to: address, credential: credential)
            self.handleItems(newValue)
        }
        
    }
    
    func unBlock(_ toUnblock: AddressName, credential: APICredential) {
        let newValue = listItems.map({ $0.name }).filter({ $0 != toUnblock })
        let newContent = newValue.joined(separator: "\n")
        let draft = PasteModel.Draft(
            address: address,
            name: "app.lol.blocked",
            content: newContent,
            listed: false
        )
        Task {
            let _ = try await self.interface.savePaste(draft, to: address, credential: credential)
            self.handleItems(newValue)
        }
    }
    
    private func handleItems(_ addresses: [AddressName]) {
        self.listItems = addresses.map({ AddressModel(name: $0) })
        Task {
            await self.perform()
        }
    }
}

class StatusLogDataFetcher: ListDataFetcher<StatusModel> {
    let displayTitle: String
    let addresses: [AddressName]
    
    override var title: String { displayTitle }
    
    init(title: String? = nil, addresses: [AddressName] = [], statuses: [StatusModel] = [], interface: DataInterface) {
        self.displayTitle = title ?? {
            switch addresses.count {
            case 0:
                return "status"
            case 1:
                return "@/statuses"
            default:
                return "statuses"
            }
        }()
        self.addresses = addresses
        super.init(items: statuses, interface: interface)
    }
    
    override func throwingRequest() async throws {
        Task {
            if addresses.isEmpty {
                let statuses = try await interface.fetchStatusLog()
                self.listItems = statuses
            } else {
                let statuses = try await interface.fetchAddressStatuses(addresses: addresses)
                self.listItems = statuses
            }
            self.fetchFinished()
        }
    }
}

class StatusDataFetcher: DataFetcher {
    let address: AddressName
    let id: String
    
    var status: StatusModel?
    
    init(id: String, from address: String, interface: DataInterface) {
        self.address = address
        self.id = id
        super.init(interface: interface)
    }
    
    override func throwingRequest() async throws {
        status = try await interface.fetchAddressStatus(id, from: address)
        threadSafeSendUpdate()
    }
}



class NowGardenDataFetcher: ListDataFetcher<NowListing> {
    override var title: String {
        "now.garden🌷"
    }
    override func throwingRequest() async throws {
        Task {
            let garden = try await interface.fetchNowGarden()
            DispatchQueue.main.async {
                self.listItems = garden
                self.fetchFinished()
            }
        }
    }
}

class AddressProfileDataFetcher: DataFetcher {
    
    let addressName: AddressName
    let credential: APICredential?
    
    var html: String?
    
    init(name: AddressName, credential: APICredential? = nil, interface: DataInterface) {
        self.addressName = name
        self.credential = credential
        super.init(interface: interface)
    }
    
    override func throwingRequest() async throws {
        guard !addressName.isEmpty else {
            return
        }
        Task {
            let profile = try await interface.fetchAddressProfile(addressName, credential: credential)
            self.html = profile?.content
            self.fetchFinished()
        }
    }
    
    var theme: String {
        return ""
    }
    
    var imageURL: URL? {
        let firstSplit = html?.split(separator: "<")
        guard let important = firstSplit?.first(where: { line in
            line.contains("property=\"og:image")
        }) else {
            return nil
        }
        let trimmingEnd = important.split(separator: "\">")
        guard let almostThere = trimmingEnd.first else {
            return nil
        }
        let finallyThere = almostThere.split(separator: "meta property=\"og:image\" content=\"")
        guard let finally = finallyThere.first else {
            return nil
        }
        return URL(string: String(finally))
    }
    
    override var noContent: Bool {
        !loading && (html ?? "").isEmpty
    }
    
    override var summaryString: String? {
        guard !noContent else {
            return super.summaryString
        }
        return DateFormatter.short.string(from: Date())
    }
}

@MainActor
class AddressNowDataFetcher: DataFetcher {
    let addressName: AddressName
    
    var content: String?
    var updated: Date?
    
    var listed: Bool?
    
    var html: String?
    
    init(name: AddressName, interface: DataInterface) {
        self.addressName = name
        super.init(interface: interface)
    }
    
    override func throwingRequest() async throws {
        guard !addressName.isEmpty else {
            return
        }
        Task {
            do {
                let now = try await interface.fetchAddressNow(addressName)
                self.content = now?.content
                self.html = now?.html
                self.updated = now?.updated
                self.listed = now?.listed
            } catch {
                handle(error)
            }
            self.fetchFinished()
        }
    }
    
    override var noContent: Bool {
        !loading && (content ?? "").isEmpty
    }
    
    override var summaryString: String? {
        let supe = super.summaryString
        if supe != nil {
            return supe
        }
        return ""
    }
}

class AccountPastesDataFetcher: ListDataFetcher<PasteModel> {
    let addresses: [AddressName]
    let credential: APICredential
    
    var lists: [AddressName: [PasteModel]] = [:]
    override var listItems: [PasteModel] {
        get {
            lists.reduce([], { $0 + $1.value })
        }
        set {
            let oldValue = listItems
            var toInsert: Set<PasteModel> = []
            var toRemove: Set<PasteModel> = []
            Array(Set<PasteModel>(oldValue + newValue)).forEach({ model in
                if oldValue.contains(model) && !newValue.contains(model) {
                    toRemove.insert(model)
                } else if !oldValue.contains(model) && newValue.contains(model) {
                    toInsert.insert(model)
                }
            })
            
            toRemove.forEach { model in
                var items = lists[model.addressName] ?? []
                if let index = items.firstIndex(of: model) {
                    items.remove(at: index)
                }
                lists[model.addressName] = items
            }
            toInsert.forEach { model in
                var items = lists[model.addressName] ?? []
                items.append(model)
                lists[model.addressName] = items
            }
        }
    }
    
    override var title: String {
        "@/pastes"
    }
    
    init(addresses: [AddressName], interface: DataInterface, credential: APICredential) {
        self.addresses = addresses
        self.credential = credential
        super.init(interface: interface)
    }
    
    override func throwingRequest() async throws {
        self.listItems = []
        guard !addresses.isEmpty else { return fetchFinished() }
        Task {
            for address in addresses {
                do {
                    let pastes = try await interface.fetchAddressPastes(address, credential: credential)
                    self.lists[address] = pastes
                    self.fetchFinished()
                } catch {
                    // Check error
                    throw error
                }
            }
        }
    }
    
    override func fetchFinished() {
        guard addresses.count == lists.count else {
            return
        }
        super.fetchFinished()
    }
}

class AddressPasteBinDataFetcher: ListDataFetcher<PasteModel> {
    let addressName: AddressName
    let credential: APICredential?
    
    override var title: String {
        "\(addressName.addressDisplayString).paste"
    }
    
    init(name: AddressName, pastes: [PasteModel] = [], interface: DataInterface, credential: APICredential?) {
        self.addressName = name
        self.credential = credential
        super.init(items: pastes, interface: interface)
    }
    
    override func throwingRequest() async throws {
        guard !addressName.isEmpty else {
            return
        }
        Task {
            let pastes = try await interface.fetchAddressPastes(addressName, credential: credential)
            DispatchQueue.main.async {
                self.listItems = pastes
                self.fetchFinished()
            }
        }
    }
}

class AddressPasteDataFetcher: DataFetcher {
    let addressName: AddressName
    let title: String
    let credential: APICredential?
    
    var paste: PasteModel?
    
    init(name: AddressName, title: String, interface: DataInterface, credential: APICredential? = nil) {
        self.addressName = name
        self.title = title
        self.credential = credential
        super.init(interface: interface)
    }
    
    override func throwingRequest() async throws {
        Task {
            paste = try await interface.fetchPaste(title, from: addressName, credential: credential)
            threadSafeSendUpdate()
        }
    }
    
    override var noContent: Bool {
        !loading && paste == nil
    }
}

class AddressPURLDataFetcher: DataFetcher {
    let addressName: AddressName
    let title: String
    let credential: APICredential?
    
    var purlContent: String?
    
    var purl: PURLModel?
    
    init(name: AddressName, title: String, interface: DataInterface, credential: APICredential? = nil) {
        self.addressName = name
        self.title = title
        self.credential = credential
        super.init(interface: interface)
    }
    
    override func throwingRequest() async throws {
        Task {
            if let credential = credential {
                purl = try await interface.fetchPURL(title, from: addressName, credential: credential)
            } else {
                let addressPurls = try await interface.fetchAddressPURLs(addressName, credential: nil)
                purl = addressPurls.first(where: { $0.value == title })
            }
            purlContent = try await interface.fetchPURLContent(title, from: addressName, credential: credential)
            fetchFinished()
        }
    }
    
    override var noContent: Bool {
        !loading && purl == nil
    }
}

class AddressPURLsDataFetcher: ListDataFetcher<PURLModel> {
    let addressName: AddressName
    let credential: APICredential?
    
    override var title: String {
        "\(addressName.addressDisplayString).PURLs"
    }
    
    init(name: AddressName, purls: [PURLModel] = [], interface: DataInterface, credential: APICredential?) {
        self.addressName = name
        self.credential = credential
        super.init(items: purls, interface: interface)
    }
    
    override func throwingRequest() async throws {
        Task {
            let purls = try await interface.fetchAddressPURLs(addressName, credential: credential)
            self.listItems = purls
            self.fetchFinished()
        }
    }
}

class AccountPURLsDataFetcher: ListDataFetcher<PURLModel> {
    let addresses: [AddressName]
    let credential: APICredential
    
    var lists: [AddressName: [PURLModel]] = [:]
    override var listItems: [PURLModel] {
        get {
            lists.reduce([], { $0 + $1.value })
        }
        set {
            let oldValue = listItems
            var toInsert: Set<PURLModel> = []
            var toRemove: Set<PURLModel> = []
            Array(Set<PURLModel>(oldValue + newValue)).forEach({ model in
                if oldValue.contains(model) && !newValue.contains(model) {
                    toRemove.insert(model)
                } else if !oldValue.contains(model) && newValue.contains(model) {
                    toInsert.insert(model)
                }
            })
            
            toRemove.forEach { model in
                var items = lists[model.addressName] ?? []
                if let index = items.firstIndex(of: model) {
                    items.remove(at: index)
                }
                lists[model.addressName] = items
            }
            toInsert.forEach { model in
                var items = lists[model.addressName] ?? []
                items.append(model)
                lists[model.addressName] = items
            }
        }
    }
    
    override var title: String {
        "@/PURLs"
    }
    
    init(addresses: [AddressName], interface: DataInterface, credential: APICredential) {
        self.addresses = addresses
        self.credential = credential
        super.init(interface: interface)
    }
    
    override func throwingRequest() async throws {
        self.listItems = []
        guard !addresses.isEmpty else { return fetchFinished() }
        Task {
            for address in addresses {
                do {
                    let purls = try await interface.fetchAddressPURLs(address, credential: credential)
                    self.lists[address] = purls
                    self.fetchFinished()
                } catch {
                    // Check error
                    throw error
                }
            }
        }
    }
    
    override func fetchFinished() {
        guard addresses.count == lists.count else {
            return
        }
        super.fetchFinished()
    }
}

@MainActor
class AddressPrivateSummaryDataFetcher: AddressSummaryDataFetcher {
    @ObservedObject
    var blockedFetcher: AddressBlockListDataFetcher
    
    @ObservedObject
    var profilePoster: ProfileDraftPoster
    @ObservedObject
    var nowPoster: NowDraftPoster
    
    init(
        name: AddressName,
        interface: DataInterface,
        credential: APICredential
    ) {
        self.blockedFetcher = .init(address: name, credential: credential, interface: interface)
        
        self.profilePoster = .init(
            name, 
            draftItem: .init(
                address: name,
                content: "",
                publish: true
            ),
            interface: interface, 
            credential: credential
        )!
        self.nowPoster = .init(
            name,
            draftItem: .init(
                address: name,
                content: "",
                listed: true
            ),
            interface: interface,
            credential: credential
        )!
        
        super.init(name: name, interface: interface)
        
        self.profileFetcher = .init(name: addressName, credential: credential, interface: interface)
        self.followingFetcher = .init(address: addressName, credential: credential, interface: interface)
        
        self.purlFetcher = .init(name: addressName, interface: interface, credential: credential)
        self.pasteFetcher = .init(name: addressName, interface: interface, credential: credential)
    }
    
    override func perform() async {
        guard !addressName.isEmpty else {
            return
        }
        await super.perform()
        await blockedFetcher.perform()
    }
}

class AddressSummaryDataFetcher: DataFetcher {
    
    let addressName: AddressName
    
    var verified: Bool?
    var url: URL?
    var registered: Date?
    
    var iconURL: URL? {
        addressName.addressIconURL
    }
    
    var iconFetcher: AddressIconDataFetcher
    var profileFetcher: AddressProfileDataFetcher
    var nowFetcher: AddressNowDataFetcher
    var purlFetcher: AddressPURLsDataFetcher
    var pasteFetcher: AddressPasteBinDataFetcher
    var statusFetcher: StatusLogDataFetcher
    var bioFetcher: AddressBioDataFetcher
    
    var followingFetcher: AddressFollowingDataFetcher
    
    init(
        name: AddressName,
        interface: DataInterface
    ) {
        self.addressName = name
        self.iconFetcher = .init(address: name, interface: interface)
        self.profileFetcher = .init(name: name, credential: nil, interface: interface)
        self.nowFetcher = .init(name: name, interface: interface)
        self.purlFetcher = .init(name: name, interface: interface, credential: nil)
        self.pasteFetcher = .init(name: name, interface: interface, credential: nil)
        self.statusFetcher = .init(addresses: [name], interface: interface)
        self.bioFetcher = .init(address: name, interface: interface)
        
        self.followingFetcher = .init(address: name, credential: nil, interface: interface)
        
        super.init(interface: interface)
    }
    
    override func perform() async {
        guard !addressName.isEmpty else {
            return
        }
        await super.perform()
        
        await iconFetcher.updateIfNeeded()
        await profileFetcher.updateIfNeeded()
        await nowFetcher.updateIfNeeded()
        await purlFetcher.updateIfNeeded()
        await pasteFetcher.updateIfNeeded()
        await statusFetcher.updateIfNeeded()
        await bioFetcher.updateIfNeeded()
        await followingFetcher.updateIfNeeded()
    }
    
    override func throwingRequest() async throws {
        guard !addressName.isEmpty else {
            return
        }
        Task {
            url = URL(string: "https://\(addressName).omg.lol")
            let info = try await interface.fetchAddressInfo(addressName)
            self.verified = false
            self.registered = info.registered
            self.url = info.url
            
            self.fetchFinished()
        }
    }
}
