
import Foundation

public struct NowListing: Hashable, Identifiable {
    public var id: String { owner+url }
    let owner: AddressName
    let url: String
    let updated: Date
}
