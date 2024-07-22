import SwiftData
import SwiftUI

public struct omgui: View {
    let clientInfo: ClientInfo
    let dataInterface: DataInterface
    
    var modelContainer: ModelContainer = {
        do {
            return try ModelContainer(
                for:
                    AddressBioModel.self,
                    StatusModel.self,
                    AddressWebpageModel.self,
                    AddressProfileModel.self,
                    AddressNowModel.self,
                    AddressPURLModel.self,
                    AddressPasteModel.self,
                    AddressInfoModel.self,
                    AddressNameModel.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
        } catch {
            fatalError("Failed to create model context")
        }
    }()
    
    public init(client: ClientInfo, interface: DataInterface) {
        self.clientInfo = client
        self.dataInterface = interface
    }
    
    public var body: some View {
        RootView(
            fetchConstructor: .init(
                client: clientInfo,
                interface: dataInterface,
                container: modelContainer
            )
        )
        .modelContainer(modelContainer)
    }
}
