import SwiftUI

@available(macCatalyst 16.1, *)
struct AccountView: View {
    @EnvironmentObject
    var model: AppModel
    
    let activeAddress: AddressModel?
    
    var displayString: String {
        activeAddress?.name.addressDisplayString ?? "Sign in"
    }
    
    var body: some View {
        Button {
            model.accountModel.showingAccountModal.toggle()
        } label: {
            Image(systemName: "person.crop.square")
            
            Text(displayString)
        }
    }
}
