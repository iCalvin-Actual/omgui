import AuthenticationServices
import SwiftUI

@available(iOS 16.1, *)
struct ManageAccountView: View {
    @Binding
    var show: Bool
    
    @EnvironmentObject
    var appModel: AppModel
    
    var authFetcher: AccountAuthDataFetcher
    
    var tokenSink: AnyCancellable?
    
    init(show: Binding<Bool>) {
        self.show = show
        
        self.authFetcher = appModel.fetchConstructor.credentialFetcher()
        tokenSink = authFetcher.$authToken.sink(receiveValue: { newValue in
            guard let auth = newValue else {
                return
            }
            appModel.login(auth)
        })
    }
    
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
                        await authFetcher.update()
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

