import SwiftUI

public struct PasteModel: Hashable, Identifiable {
    public var id: String { owner+name+(content ?? "") }
    let owner: AddressName
    let name: String
    var content: String?
    
    public init(owner: AddressName, name: String, content: String? = nil) {
        self.owner = owner
        self.name = name
        self.content = content
    }
}
