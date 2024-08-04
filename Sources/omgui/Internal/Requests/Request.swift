//
//  Request.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import Combine
import Foundation

@MainActor
class Request: NSObject, ObservableObject {
    struct AutomationPreferences {
        var autoLoad: Bool
        var reloadDuration: TimeInterval?
        
        init(_ autoLoad: Bool = true, reloadDuration: TimeInterval? = nil) {
            self.reloadDuration = reloadDuration
            self.autoLoad = autoLoad
        }
    }
    
    let interface: DataInterface
    
    var loaded: Bool = false
    var loading: Bool = false
    
    var error: Error?
    
    var requests: [AnyCancellable] = []
    
    var noContent: Bool {
        !loading
    }
    
    init(interface: DataInterface, automation: AutomationPreferences = .init()) {
        self.interface = interface
        super.init()
        
        if automation.autoLoad {
            Task {
                await perform()
            }
        }
    }
    
    var requestNeeded: Bool { !loaded }
    
    func updateIfNeeded(forceReload: Bool = false) async {
        guard forceReload || (loading && requestNeeded) else {
            print("NOT performing request")
            return
        }
        await perform()
    }
    
    func perform() async {
        loading = true
        publish()
        do {
            try await throwingRequest()
        } catch {
            handle(error)
        }
    }
    
    func throwingRequest() async throws {
        fetchFinished()
    }
    
    func fetchFinished() {
        loaded = true
        loading = false
        publish()
    }
    
    func handle(_ incomingError: Error) {
        loaded = false
        loading = false
        error = incomingError
        publish()
    }
    
    func publish() {
        objectWillChange.send()
    }
}
