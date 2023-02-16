import SwiftUI

public struct StatusModel: Hashable, Identifiable {
    public let id: String
    let address: AddressName
    let posted: Date
    
    let status: String
    
    let emoji: String?
    let linkText: String?
    let link: URL?
}

struct GroupStatusLogModel {
    let displayTitle: String?
    let statuses: [StatusModel]
}

