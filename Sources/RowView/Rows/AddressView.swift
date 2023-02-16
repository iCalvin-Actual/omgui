import SwiftUI

@available(iOS 16.1, *)
struct AddressView: View {
    
    let model: AddressModel
    
    @Environment(\.isSearching) var isSearching
    
    var narrow: Bool {
        isSearching
    }
    
    init(model: AddressModel) {
        self.model = model
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if !narrow {
                Spacer()
            }
            Text(model.addressName.addressDisplayString)
                .font(.title)
                .bold()
                .padding(.vertical, !narrow ? 8 : 0)
                .padding(.bottom, 4)
                .padding(.trailing, 4)
            
            
            HStack(alignment: .bottom) {
                if !narrow {
                    Text("")
                        .font(.headline)
                        .bold()
                    Spacer()
                    if let registered = model.registered {
                        Text("Since \(DateFormatter.monthYear.string(from: registered))")
                            .font(.subheadline)
                            .bold(false)
                    }
                } else {
                    Spacer()
                }
            }
            .padding(.trailing)
        }
        .padding(.vertical)
        .padding(.leading, 32)
        .background(Color.yellow)
        .cornerRadius(24)
        .fontDesign(.serif)
    }
}
