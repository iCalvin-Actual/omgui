//
//  Request.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import Combine
import Foundation

protocol RequestProtocol: Observable, Sendable {
    var interface: DataInterface { get }
    
    func startLoading()
    func finishedLoading()
    func resetLoadingState()
    
    func updateIfNeeded(forceReload: Bool) async
    func perform() async
    func throwingRequest() async throws
    func fetchFinished()
}

extension RequestProtocol {
    func configure(_ automation: AutomationPreferences = .init()) {
        resetLoadingState()
        if automation.autoLoad {
            updateIfNeeded(forceReload: true)
        }
    }
    
    func updateIfNeeded(forceReload: Bool = false) {
        guard forceReload else {
            print("NOT performing request")
            return
        }
        Task {
            await perform()
        }
    }
    
    func perform() async {
        startLoading()
        do {
            try await throwingRequest()
        } catch {
            await handle(error)
        }
    }
    
    func throwingRequest() async throws {
        await fetchFinished()
    }
    
    func fetchFinished() async {
        finishedLoading()
    }
    
    func handle(_ incomingError: Error) async {
        finishedLoading()
    }
}

//actor FinalRequest {
//    
//    let interface: DataInterface
//    
//    var loaded: Bool = false
//    var loading: Bool = false
//    
//    var error: Error?
//    
//    var requests: [AnyCancellable] = []
//    
//    var noContent: Bool {
//        !loading
//    }
//    
//    init(interface: DataInterface, automation: AutomationPreferences = .init()) {
//        self.interface = interface
//        
////        self.configure(automation)
//    }
//    
//    var requestNeeded: Bool { !loaded && noContent }
//    
//    func updateIfNeeded(forceReload: Bool) async {
//        guard forceReload || (loading && requestNeeded) else {
//            print("NOT performing request")
//            return
//        }
//        Task {
//            await perform()
//        }
//    }
//    
//    nonisolated
//    func startLoading() {
//        Task {
//            loaded = true
//        }
//    }
//    
//    func finishedLoading() async {
//        loaded = true
//        loading = false
//    }
//    
//    func resetLoadingState() async {
//        loaded = false
//        loading = false
//    }
//}

struct AutomationPreferences {
    var autoLoad: Bool
    var reloadDuration: TimeInterval?
    
    init(_ autoLoad: Bool = true, reloadDuration: TimeInterval? = nil) {
        self.reloadDuration = reloadDuration
        self.autoLoad = autoLoad
    }
}

class Request: ObservableObject {
    
    let interface: DataInterface
    
    @Published
    var loaded: Bool = false
    @Published
    var loading: Bool = false
    
    @Published
    var error: Error?
    
    var requests: [AnyCancellable] = []
    
    var noContent: Bool {
        !loading
    }
    
    init(interface: DataInterface, automation: AutomationPreferences = .init()) {
        self.interface = interface
        
        self.configure(automation)
    }
    
    func configure(_ automation: AutomationPreferences = .init()) {
        self.loaded = false
        self.loading = false
//        if automation.autoLoad {
//            Task {
//                updateIfNeeded(forceReload: true)
//            }
//        }
    }
    
    var requestNeeded: Bool { !loaded }
    
    func updateIfNeeded(forceReload: Bool = false) async {
        guard forceReload || (loading && requestNeeded) else {
            return
        }
        await perform()
    }
    
    func perform() async {
        do {
            try await throwingRequest()
        } catch {
            print("🚨🚨🚨 Caught error: \(error) in \(self)")
            await handle(error)
        }
    }
    
    func throwingRequest() async throws {
        await fetchFinished()
    }
    
    @MainActor
    func fetchFinished() async {
        loaded = true
        loading = false
    }
    
    @MainActor
    func handle(_ incomingError: Error) {
        loaded = false
        loading = false
        error = incomingError
    }
}
