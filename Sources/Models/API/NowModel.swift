
import Foundation

public struct NowModel: Hashable, Identifiable {
    public var id: String { owner+url }
    let owner: AddressName
    let url: String
    let updated: Date
}
