import SwiftUI

public struct NowModel {
    let owner: AddressName
    
    let content: String?
    let updated: Date?
    let listed: Bool?
    
    public init(owner: AddressName, content: String? = nil, updated: Date? = nil, listed: Bool? = nil) {
        self.owner = owner
        self.content = content
        self.updated = updated
        self.listed = listed
    }
}
