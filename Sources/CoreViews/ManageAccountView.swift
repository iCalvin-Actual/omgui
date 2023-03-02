import AuthenticationServices
import Combine
import SwiftUI

@available(iOS 16.1, *)
struct ManageAccountView: View {
    @Binding
    var show: Bool
    
    @EnvironmentObject
    var appModel: AppModel
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .top) {
                Spacer()
                Button(action: { 
                    self.show.toggle()
                }, label: {
                    Text("Close")
                })
            }
            if appModel.accountModel.signedIn {
                Text("Logged in")
            } else {
                Button(action: {
                    Task {
                        self.appModel.authenticate()
                    }
                }, label: {
                    Label("Login on omg.lol", systemImage: "key")
                        .padding()
                        .background(in: Capsule(), fillStyle: .init(eoFill: true, antialiased: true))
                })
            }
            Spacer()
        }
        .padding()
    }
}

