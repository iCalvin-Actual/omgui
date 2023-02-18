import SwiftUI

@MainActor
public class SceneModel: ObservableObject {
    var selectedAddress: AddressModel?
    var selectedStatus: StatusModel?
    var selectedNow: NowListing?
    var selectedPURL: PURLModel?
    var selectedPaste: PasteModel?
    
    @Published
    var showingSettings: Bool = false
    
    public init() {
    }
}
