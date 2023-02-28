import SwiftUI

@available(iOS 16.1, *)
@available(macCatalyst 16.1, *)
struct AccountView: View {
    
    @Binding
    var showAccount: Bool
    
    let activeAddress: AddressName?
    
    var displayString: String {
        activeAddress?.addressDisplayString ?? "Sign in"
    }
    
    var body: some View {
        Button {
            showAccount.toggle()
        } label: {
            Image(systemName: "person.crop.square")
            
            Text(displayString)
        }
    }
}
