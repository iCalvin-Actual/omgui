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
    
    func updateIfNeeded() async {
        guard !loading else {
            return
        }
        await perform()
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
