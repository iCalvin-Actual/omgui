import SwiftUI

struct AccountView: View {
    @EnvironmentObject
    var model: AccountModel
    
    let activeAddress: AddressModel?
    
    var displayString: String {
        activeAddress?.name.addressDisplayString ?? "Sign in"
    }
    
    var body: some View {
        Button {
            model.showingAccountModal.toggle()
        } label: {
            Image(systemName: "person.crop.square")
            
            Text(displayString)
        }
    }
}
