import SwiftUI

public struct AddressModel: Hashable, Identifiable, RawRepresentable, Codable {
    public init?(rawValue: String) {
        self = AddressModel(name: rawValue)
    }
    
    public var rawValue: String { name }
    public var id: String { rawValue }
    
    let name: AddressName
    var url: URL?
    var registered: Date?
    
    public init(name: AddressName, url: URL? = nil, registered: Date? = nil) {
        self.name = name
        self.url = url
        self.registered = registered
    }
}
