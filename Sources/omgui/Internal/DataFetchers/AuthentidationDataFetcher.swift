//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import AuthenticationServices
import Combine

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
