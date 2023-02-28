import SwiftUI

public typealias AddressName = String
public extension AddressName {
    var addressDisplayString: String { "@\(self)"}
}
enum Context {
    case column
    case profile
}

@available(iOS 16.1, *)
public struct UIDotAppDotLOL: View {
    @StateObject
    var state: AppModel
    
    public init(interface: OMGDataInterface = SampleData()) {
        self._state = StateObject(wrappedValue: AppModel(interface: interface))
    }
    
    public var body: some View {
        CoreNavigationView()
            .environmentObject(state)
    }
}
