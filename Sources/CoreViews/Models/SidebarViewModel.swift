import SwiftUI

@MainActor
@available(iOS 16.1, *)
class SidebarViewModel: ObservableObject {
    
    @ObservedObject
    var appModel: AppModel
    
    init(appModel: AppModel) {
        self.appModel = appModel
    }
    
    enum Group: Int, CaseIterable, Hashable, Identifiable {
        var id: Int { rawValue }
        
        case directory
        case status
        case saved
        case weblog
        case comingSoon
        
        var displayName: String {
            switch self {
            case .directory:
                return "omg.lol"
            case .status:
                return "status.lol"
            case .saved:
                return "cache.app.lol"
            case .weblog:
                return "blog.app.lol"
            case .comingSoon:
                return "Coming Soon"
            }
        }
    }
    
    var groups: [Group] { 
        [.directory, .status, .saved]
    }
    
    func content(in group: Group) -> [NavigationColumn] {
        switch group {
        case .directory:
            return [
                .search,
                .garden,
            ]
        case .status:
            return [
                .community
            ]
        case .saved:
            return appModel.accountModel.pinned.sorted().map({ .pinned($0) })
        default:
            return [
            ]
        }
    }
}
