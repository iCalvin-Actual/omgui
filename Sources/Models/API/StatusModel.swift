import SwiftUI

public struct StatusModel: Hashable, Identifiable {
    public let id: String
    let address: AddressName
    let posted: Date
    
    let status: String
    
    let emoji: String?
    let linkText: String?
    let link: URL?
    
    public init(id: String, address: AddressName, posted: Date, status: String, emoji: String? = nil, linkText: String? = nil, link: URL? = nil) {
        self.id = id
        self.address = address
        self.posted = posted
        self.status = status
        self.emoji = emoji
        self.linkText = linkText
        self.link = link
    }
}

struct GroupStatusLogModel {
    let displayTitle: String?
    let statuses: [StatusModel]
}

