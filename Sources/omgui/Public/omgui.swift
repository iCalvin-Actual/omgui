import SwiftUI

public struct omgui: View {
    @StateObject
    var state: AppModel
    
    public init(client: ClientInfo, interface: DataInterface = SampleData()) {
        self._state = StateObject(wrappedValue: AppModel(client: client, dataInterface: interface))
    }
    
    public var body: some View {
        RootView()
            .environmentObject(state)
    }
}
