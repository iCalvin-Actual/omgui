//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 2/15/23.
//

import Foundation

extension ServiceInfoModel {
    static var sample: ServiceInfoModel {
        ServiceInfoModel(
            members:1600,
            addresses: 1800,
            profiles: 666
        )
    }
}

extension StatusModel {
    static func random(from: AddressName? = nil) -> StatusModel? {
        let contentItems = ["Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat", " Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.", "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."]
        let emojiItems = ["🙈", "🤷", "😘", "🤣", "😅", "🦖", "🤓", "🙃", "✨", "🎉", "🤔", "😍", "🙊", "😉", "🖤", "🤩"]
        guard
            let address = from,
            let content = contentItems.randomElement(),
            let emoji = emojiItems.randomElement()
        else {
            return nil
        }
        return StatusModel(
            id: UUID().uuidString,
            address: address,
            posted: Date(),
            status: content,
            emoji: emoji,
            linkText: nil,
            link: nil
        )
    }
}

extension PURLModel {
    static func random(from: AddressName? = nil) -> PURLModel? {
        let contentItems = ["https://daringfireball.net", "https://atp.fm", "https://relay.fm"]
        guard
            let address = from,
            let content = contentItems.randomElement()
        else {
            return nil
        }
        return PURLModel(
            owner: address,
            destination: content,
            value: String(UUID().uuidString.prefix(3))
        )
    }
}

extension PasteModel {
    static func random(from: AddressName? = nil) -> PasteModel? {
        let contentItems = ["Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat", " Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.", "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."]
        guard
            let address = from,
            let content = contentItems.randomElement()
        else {
            return nil
        }
        return PasteModel(
            owner: address,
            name: String(UUID().uuidString.prefix(3)),
            content: content
        )
    }
}
