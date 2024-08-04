import Blackbird
import SwiftUI

public struct omgui: View {
    
    @AppStorage("app.lol.cache.myAddresses")
    var localAddressesCache: String = ""
    var myAddresses: [String] {
        get {
            localAddressesCache
                .split(separator: "&&&")
                .map({ String($0) })
        }
        set {
            localAddressesCache = newValue.joined(separator: "&&&")
        }
    }
    @SceneStorage("app.lol.following")
    var appliedFollow: String = ""
    var followed: [AddressName] {
        appliedFollow
            .split(separator: "&&&")
            .map({ String($0) })
    }
    @SceneStorage("app.lol.blocked")
    var appliedBlocked: String = ""
    var blocked: [AddressName] {
        appliedBlocked
            .split(separator: "&&&")
            .map({ String($0) })
    }
    
    
    let clientInfo: ClientInfo
    let dataInterface: DataInterface
    
    @StateObject
    var database = try! Blackbird.Database.inMemoryDatabase()
    
    public init(client: ClientInfo, interface: DataInterface) {
        self.clientInfo = client
        self.dataInterface = interface
    }
    
    public var body: some View {
        RootView()
            .environment(\.blackbirdDatabase, database)
            .environment(\.fetcher,
                FetchConstructor(
                    client: clientInfo,
                    interface: dataInterface,
                    lists: .init(
                        myAddresses: myAddresses,
                        following: followed,
                        blocked: blocked
                    ),
                    database: database
                )
            )
    }
}
