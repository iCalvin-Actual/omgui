//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Foundation

public final class SampleData: DataInterface {
    private var artificalDelay: UInt64 {
        return UInt64(Double.random(min: 0.02, max: 5.0) * Double(NSEC_PER_SEC))
    }
    
    public func authURL() -> URL? {
        URL(string: "https://home.omg.lol")
    }
    
    public init() { }
    
    @MainActor
    public func fetchAccessToken(authCode: String, clientID: String, clientSecret: String, redirect: String) async throws -> String? {
        try await Task.sleep(nanoseconds: artificalDelay)
        return authCode
    }
    
    public func fetchServiceInfo() async throws -> ServiceInfoModel {
        try await Task.sleep(nanoseconds: artificalDelay)
        return
            .init(members: 500, addresses: 400, profiles: 300)
    }
    
    public func fetchAddressAvailability(_ address: AddressName) async throws -> AddressAvailabilityModel {
        try await Task.sleep(nanoseconds: artificalDelay)
        return .init(address: address, available: true, punyCode: nil)
    }

    public func fetchAddressDirectory() async throws -> [AddressName] {
        try await Task.sleep(nanoseconds: UInt64(2 * Double(NSEC_PER_SEC)))
        return ["app", "appleAppStoreReview", "calvin", "jwithy", "jmj", "kris", "spalger", "joshbrez"]
    }
    
    public func fetchAccountInfo(_ address: AddressName, credential: APICredential) async throws -> AccountInfoModel? {
        try await Task.sleep(nanoseconds: artificalDelay)
        guard !credential.isEmpty else {
            return nil
        }
        return .init(name: "Firstname", created: Date.init(timeIntervalSinceNow: -1000000))
    }
    
    public func fetchAccountAddresses(_ credential: String) async throws -> [AddressName] {
        try await Task.sleep(nanoseconds: artificalDelay)
        guard !credential.isEmpty else {
            return []
        }
        return ["app", "calvin"]
    }
    
    public func fetchNowGarden() async throws -> [NowListing] {
        let directory = try await fetchAddressDirectory()
        try await Task.sleep(nanoseconds: artificalDelay)
        return directory.map { name in
            return .init(owner: name, url: "https://\(name).omg.lol", updated: Date())
        }
    }
    
    public func fetchAddressInfo(_ name: AddressName) async throws -> AddressModel {
        try await Task.sleep(nanoseconds: artificalDelay)
        return .sample(with: name)
    }
    
    public func fetchAddressNow(_ name: AddressName) async throws -> NowModel? {
        try await Task.sleep(nanoseconds: artificalDelay)
        return .sample(with: name)
    }
    
    public func saveAddressNow(_ name: AddressName, content: String, credential: APICredential) -> NowModel? {
        return .sample(with: name)
    }
    
    public func fetchAddressPURLs(_ name: AddressName, credential: APICredential?) async throws -> [PURLModel] {
        try await Task.sleep(nanoseconds: artificalDelay)
        return [
            .sample(with: name),
            .sample(with: name),
            .sample(with: name)
        ]
    }
    
    public func fetchPURL(_ id: String, from address: AddressName, credential: APICredential?) async throws -> PURLModel? {
        try await Task.sleep(nanoseconds: artificalDelay)
        return .sample(with: address)
    }
    
    public func deletePURL(_ id: String, from address: AddressName, credential: APICredential) async throws {
    }
    
    public func fetchPURLContent(_ id: String, from address: AddressName, credential: APICredential?) async throws -> String? {
        try await Task.sleep(nanoseconds: artificalDelay)
        let content = String.htmlContent
        return content
    }
    
    public func savePURL(_ draft: PURLModel.Draft, to address: AddressName, credential: APICredential) async throws -> PURLModel? {
        try await Task.sleep(nanoseconds: artificalDelay)
        return PURLModel(owner: address, name: draft.name, content: draft.content, listed: true)
    }
    
    public func fetchAddressPastes(_ name: AddressName, credential: APICredential?) async throws -> [PasteModel] {
        try await Task.sleep(nanoseconds: artificalDelay)
        return [
            .sample(with: name),
            .sample(with: name),
            .sample(with: name)
        ]
    }
    
    public func fetchPaste(_ id: String, from address: AddressName, credential: APICredential? = nil) async throws -> PasteModel? {
        try await Task.sleep(nanoseconds: artificalDelay)
        if id == "app.lol.following" {
            return .followed(with: address)
        } else if id == "app.lol.blocked" {
            return .blocked(with: address)
        }
        return .sample(with: address)
    }
    
    public func deletePaste(
        _ id: String,
        from address: AddressName,
        credential: APICredential
    ) async throws {
    }
    
    public func savePaste(
        _ draft: PasteModel.Draft,
        to address: AddressName,
        credential: APICredential
    ) async throws -> PasteModel? {
        try await fetchPaste(draft.name, from: address, credential: credential)
    }
    
    public func fetchStatusLog() async throws -> [StatusModel] {
        try await Task.sleep(nanoseconds: artificalDelay)
        var statuses: [StatusModel] = []
        let directory = ["app", "appleAppStoreReview", "calvin", "jwithy", "jmj", "kris", "spalger", "joshbrez"]
        for _ in 0...50 {
            statuses.append(.sample(with: directory.randomElement()!))
        }
        return statuses
    }
    
    public func fetchAddressStatuses(addresses: [AddressName]) async throws -> [StatusModel] {
        return try await fetchStatusLog()
            .filter({ element in
                guard !addresses.isEmpty else {
                    return true
                }
                return addresses.contains(element.address)
            })
    }
    
    public func fetchAddressStatus(_ id: String, from address: AddressName) async throws -> StatusModel? {
        try await Task.sleep(nanoseconds: artificalDelay)
        return StatusModel.sample(with: address, id: id)
    }
    
    public func deleteAddressStatus(_ draft: StatusModel.Draft, from address: AddressName, credential: APICredential) async throws -> StatusModel? {
        guard let id = draft.id else {
            return nil
        }
        try await Task.sleep(nanoseconds: artificalDelay)
        return StatusModel.sample(with: address, id: id)
    }
    
    public func saveStatusDraft(_ draft: StatusModel.Draft, to address: AddressName, credential: APICredential) async throws -> StatusModel? {
        try await Task.sleep(nanoseconds: artificalDelay)
        return try await fetchAddressStatus(draft.id ?? UUID().uuidString, from: address)
    }
    
    public func fetchAddressBio(_ name: AddressName) async throws -> AddressBioModel {
        try await Task.sleep(nanoseconds: artificalDelay)
        let content = String.minimalLorum
        return .init(address: name, bio: content)
    }
    
    public func fetchAddressProfile(_ name: AddressName, credential: APICredential?) async throws -> AddressProfile? {
        try await Task.sleep(nanoseconds: artificalDelay)
        let content = String.htmlContent
        return .init(owner: name, content: content)
    }
    
    public func saveAddressProfile(_ name: AddressName, content: String, credential: APICredential) async throws -> AddressProfile? {
        try await fetchAddressProfile(name, credential: credential)
    }
    
    public func fetchThemes() async throws -> [ThemeModel] {
        try await Task.sleep(nanoseconds: artificalDelay)
        return [
            .init(id: "default", name: "Default", created: "1660967179", updated: "1660967179", author: "omg.lol", license: "MIT", description: "A friendly, simple look for your amazing profile.", preview: "")
        ]
    }
}

fileprivate extension Double {
    static var random: Double {
        return Double(arc4random()) / 0xFFFFFFFF
    }
    
    static func random(min: Double, max: Double) -> Double {
        return self.random * (max - min) + min
    }
}

fileprivate extension String {
    static var minimalLorum: String {
        """
### Just some they, ya know?
        
[Excepteur](https://app.omg.lol) sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
"""
    }
}

fileprivate extension String {
    static var lorum: String {
        """
# Lorem ipsum dolor

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

### Ut enim ad minim veniam

// Quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. [Excepteur](https://app.omg.lol) sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
"""
    }
}

extension String {
    static var htmlContent: String {
        """
<!DOCTYPE html>
<html lang="en">
  <head>
    <title>
      app.lol for iOS
    </title>
    <meta charset="utf-8">
    <meta property="og:type" content="website">
    <meta property="og:title" content="app.lol for iOS">
    <meta property="og:description" content="An Apple Native Client for omg.lol">
    <meta property="og:image" content="https://profiles.cache.lol/app/picture?v=1676318189.7229">
    <meta name="viewport" content="width=device-width">
    <link href="https://cdn.cache.lol/profiles/themes/css/base.css" rel="stylesheet">
    <link href="https://cdn.cache.lol/profiles/themes/css/purplegray.css" rel="stylesheet">
    <style>
                #footer .prami-logo {
                       theme height: 1em;
                        transition: all 0.3s ease;
                        margin: 0 .3em -.1em 0;
                }
                #footer:hover .prami-logo {
                        transform: scale(1.5) rotate(20deg);
                        transition: all 0.3s ease;
                }
    </style>
  </head>
  <body>
    <main>
      <div id="profile-picture-container">
        <img alt="app" id="profile-picture" src="https://profiles.cache.lol/app/picture?v=1676318189.7229">
      </div>
      <h1 id="name">
        app.lol
      </h1>
      <div class="metadata" id="pronouns">
        they/them
      </div>
      <div class="metadata" id="occupation">
        <i class="fa-solid fa-fw fa-briefcase"></i> App Client
      </div>
      <div id="details"></div>
      <div id="bio">
        <h3>
          Coming Soon
        </h3>
        <p>
          Are you as much a fan of <a rel="me" href="http://home.omg.lol">omg.lol</a> as we are?
        </p>
        <h4>
          YES!
        </h4>
        <p>
          We thought so!! We’re putting together a (hopefully) great native app experience, send an email to sign up for the <a rel="me" href="mailto:app@omg.lol">beta list</a> or keep up with development on our <a rel="me" href="/now">Now Page</a>
        </p>
        <h4>
          Wait, what is this?
        </h4>
        <p>
          Ooh, are you in for a treat! If you’re interested in any of the following:
        </p>
        <ul class="fa-ul">
          <li>
            <span class="fa-li"><i class="fa-solid fa-circle-info"></i></span>Having a web presence
          </li>
          <li>
            <span class="fa-li"><i class="fa-solid fa-circle-info"></i></span>Reaching people who enjoy your work
          </li>
          <li>
            <span class="fa-li"><i class="fa-solid fa-circle-info"></i></span>Staying in touch with people you love
          </li>
          <li>
            <span class="fa-li"><i class="fa-solid fa-circle-info"></i></span>Sharing links
          </li>
          <li>
            <span class="fa-li"><i class="fa-solid fa-circle-info"></i></span>Sharing thoughts
          </li>
          <li>
            <span class="fa-li"><i class="fa-solid fa-circle-info"></i></span>Email aliases
          </li>
          <li>
            <span class="fa-li"><i class="fa-solid fa-circle-info"></i></span>Supporting the open internet
          </li>
        </ul>
        <p>
          <a rel="me" href="https://home.omg.lol">omg.lol</a> is gonna get you really excited.
        </p>
        <h4>
          Okay, that’s that, who are you?
        </h4>
        <p>
          We are <code>app.lol</code>, a native client to the <code>omg.lol</code> service.
        </p>
        <p>
          Let’s break that down:
        </p>
        <p>
          <strong>Native</strong> - <code>app.lol</code> is built to run on and take advantage of Apple platforms, using modern APIs and design language, supporting system features, and exist as a thouroughly considered tool to help you, the user.
        </p>
        <p>
          <strong>Client</strong> - As nice as the web interface to <code>omg.lol</code> is, sometimes the jump to a web browser is enough to stop you from completing a thought. <code>app.lol</code> aims to help that using the <a rel="me" href="https://api.omg.lol">public APIs</a> exposed by the service. Put it right on your phone, your Mac, your iPad, your TV, wherever it fits for you.
        </p>
        <p>
          <strong>omg.lol Service</strong> - Update your <a rel="me" href="https://home.omg.lol/info/now">Now Page</a>, check the links on your profile, draft a new status and pick just the right emoji. Now you can do all of the above without needing to open a web browser.
        </p>
        <h3>
          What are you waiting for?
        </h3>
        <p>
          That's the pitch! By now you should know whether you're interested or not :) Please feel free to reach out with any questions, comments, gripes, concerns, complaints...
        </p>
        <p>
          <a rel="me" href="mailto://app@omg.lol">app@omg.lol</a>
        </p>
        <p>
          Follow development! We'll try to pose semi-regular updates on our <a rel="me" href="/now">Now Page</a>.
        </p>
      </div>
      <div id="footer">
        <a href="https://home.omg.lol/referred-by/app"><img class="prami-logo" src="https://cdn.cache.lol/img/prami_hybrid.svg"> Powered by omg.lol</a>
      </div>
    </main>
  </body>
</html>
"""
    }
}

fileprivate extension AddressModel {
    static func sample(with address: AddressName) -> AddressModel {
        .init(
            name: address,
            url: URL(string: "https://\(address).omg.lol"),
            registered: .init(timeIntervalSince1970:
                .random(min: 1600000000.0, max: 1678019926.0))
        )
    }
}

fileprivate extension NowModel {
    static func sample(with address: AddressName) -> NowModel {
        .init(
            owner: address,
            content: .lorum,
            updated: Date(timeIntervalSince1970: .random(min: 1600000000.0, max: 1678019926.0)),
            listed: .random()
        )
    }
}

fileprivate extension PURLModel {
    static func sample(with address: AddressName) -> PURLModel {
        let contentItems = ["https://daringfireball.net", "https://atp.fm", "https://relay.fm"]
        let content = contentItems.randomElement()!
        return PURLModel(
            owner: address,
            name: String(UUID().uuidString.prefix(5)),
            content: content,
            listed: true
        )
    }
}

fileprivate extension PasteModel {
    static func blocked(with address: AddressName) -> PasteModel {
        let content = """
appstoreappreview
"""
        return PasteModel(
            owner: address,
            name: String(UUID().uuidString.prefix(5)),
            content: content
        )
    }
    static func followed(with address: AddressName) -> PasteModel {
        let content = """
app
calvin
"""
        return PasteModel(
            owner: address,
            name: String(UUID().uuidString.prefix(5)),
            content: content
        )
    }
    static func sample(with address: AddressName) -> PasteModel {
        let contentItems = ["Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat", "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.", "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."]
        let content = contentItems.randomElement()!
        return PasteModel(
            owner: address,
            name: String(UUID().uuidString.prefix(5)),
            content: content
        )
    }
}

fileprivate extension StatusModel {
    static func sample(with address: AddressName, id: String? = nil) -> StatusModel {
        let contentItems = ["Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat", " Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.", "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."]
        let emojiItems = ["🙈", "🤷", "😘", "🤣", "😅", "🦖", "🤓", "🙃", "✨", "🎉", "🤔", "😍", "🙊", "😉", "🖤", "🤩"]
        let content = contentItems.randomElement()!
        let emoji = emojiItems.randomElement()!
        return StatusModel(
            id: id ?? UUID().uuidString,
            address: address,
            posted: Date(timeIntervalSince1970: .random(min: 1600000000.0, max: 1678019926.0)),
            status: content,
            emoji: emoji,
            linkText: nil,
            link: nil
        )
    }
}
