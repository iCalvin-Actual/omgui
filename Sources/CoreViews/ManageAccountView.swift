import SwiftUI

struct ManageAccountView: View {
    var body: some View {
        Text("Manage Account")
    }
}

@available(iOS 16.1, *)
class AccountFetcher: ObservableObject {
    
    init() {
        fetch()
    }
    
    func fetch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            AppModel.state.login("SomeKey")
        }
    }
}

