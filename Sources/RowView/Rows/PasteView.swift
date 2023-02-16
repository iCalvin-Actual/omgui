import SwiftUI

@available(iOS 16.1, *)
struct PasteView: View {
    let model: PasteModel
    
    @Environment(\.isSearching) var isSearching
    
    var narrow: Bool {
        isSearching
    }
    
    var body: some View {
        EmptyView()
    }
}
