
import Foundation

public struct NowListing: Hashable, Identifiable {
    public var id: String { owner+url }
    let owner: AddressName
    let url: String
    let updated: Date
    
    init(owner: AddressName, url: String, updated: Date) {
        self.owner = owner
        self.url = url
        self.updated = updated
    }
}
