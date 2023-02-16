import SwiftUI

@available(iOS 16.1, *)
struct PURLView: View {
    let model: PURLModel
    
    @Environment(\.isSearching) var isSearching
    
    var narrow: Bool {
        isSearching
    }
    
    var body: some View {
        EmptyView()
    }
}
