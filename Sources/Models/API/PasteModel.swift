import SwiftUI

public struct PasteModel: Hashable, Identifiable {
    public var id: String { owner+name+(content ?? "") }
    let owner: AddressName
    let name: String
    var content: String?
    
    init(owner: AddressName, name: String, content: String?) {
        self.owner = owner
        self.name = name
        self.content = content
    }
}
