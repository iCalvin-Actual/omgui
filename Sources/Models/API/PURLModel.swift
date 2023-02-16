import SwiftUI

public struct PURLModel: Hashable, Identifiable, RawRepresentable, Codable {
    static var separator: String { "{PURL}" }
    
    public init?(rawValue: String) {
        let split = rawValue.split(separator: Self.separator)
        guard split.count == 2 else {
            return nil
        }
        self.owner = String(split[0])
        self.value = String(split[1])
    }
    
    public var rawValue: String {
        owner+Self.separator+value
    }
    
    let owner: AddressName
    var destination: String?
    let value: String
    
    init(owner: AddressName, destination: String?, value: String) {
        self.owner = owner
        self.destination = destination
        self.value = value
    }
}

