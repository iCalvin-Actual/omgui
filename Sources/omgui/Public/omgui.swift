import Blackbird
import SwiftUI

public struct omgui: View {
    
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
                    database: database
                )
            )
    }
}
