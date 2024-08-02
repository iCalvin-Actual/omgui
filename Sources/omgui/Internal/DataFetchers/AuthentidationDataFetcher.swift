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
