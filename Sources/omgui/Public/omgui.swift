import Blackbird
import SwiftUI

public struct omgui: View {
    @StateObject
    var database = try! Blackbird.Database.inMemoryDatabase(options: [.debugPrintEveryQuery, .debugPrintEveryReportedChange])
    
    let clientInfo: ClientInfo
    let dataInterface: DataInterface
    
    public init(client: ClientInfo, interface: DataInterface) {
        self.clientInfo = client
        self.dataInterface = interface
    }
    
    public var body: some View {
        RootView(fetchConstructor: .init(client: clientInfo, interface: dataInterface, database: database))
            .environment(\.blackbirdDatabase, database)
    }
}
