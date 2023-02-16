import SwiftUI

public typealias AddressName = String
struct APICredentials {
    public let emailAddress: String
    public let authKey: String
}
public extension AddressName {
    var addressDisplayString: String { "@\(self)"}
}
enum Context {
    case column
    case profile
}

@available(iOS 16.1, *)
public struct UIDotAppDotLOL: App {
    @StateObject
    var model: AppModel = .state
    
    public init() {
    }
    
    public var body: some Scene {
        WindowGroup { 
            CoreNavigationView()
                .environmentObject(SceneModel())
                .environmentObject(model.addressDirectory)
                .environmentObject(model.accountModel)
        }
    }
}
