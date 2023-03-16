import SwiftUI

public struct omgui: View {
    @ObservedObject
    var state: AppModel
    
    public init(state: AppModel) {
        self.state = state
    }
    
    public var body: some View {
        RootView(appModel: state)
    }
}
