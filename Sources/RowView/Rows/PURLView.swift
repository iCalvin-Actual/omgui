import SwiftUI

@available(iOS 16.1, *)
struct PURLView: View {
    let model: PURLModel
    let context: Context
    
    @Environment(\.isSearching) var isSearching
    
    var narrow: Bool {
        isSearching
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if context != .profile {
                Text(model.owner.addressDisplayString)
                    .font(.title3)
                    .padding(2)
            }
            
            VStack(alignment: .leading) {
                Text(model.value)
                    .font(.largeTitle)
                    .aspectRatio(1.0, contentMode: .fit)
                    .padding(.vertical)
                
                if let destination = model.destination {
                    Text(destination)
                        .font(.caption)
                        .foregroundColor(Color(uiColor: .lightGray))
                        .padding(.bottom)
                }
            }
            .multilineTextAlignment(.leading)
            .padding(12)
            .accentColor(.primary)
            .background(Color.lolRandom(model.value))
            .cornerRadius(12, antialiased: true)
        }
    }
}
