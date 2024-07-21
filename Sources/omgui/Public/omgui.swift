import SwiftData
import SwiftUI

public struct omgui: View {
    let clientInfo: ClientInfo
    let dataInterface: DataInterface
    
    public init(client: ClientInfo, interface: DataInterface) {
        self.clientInfo = client
        self.dataInterface = interface
    }
    
    public var body: some View {
        RootView(
            fetchConstructor: .init(
                client: clientInfo,
                interface: dataInterface
            )
        )
        .modelContainer(for: dataInterface.swiftModels, inMemory: true)
    }
}
