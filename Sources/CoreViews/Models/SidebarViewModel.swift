import SwiftUI

@MainActor
@available(iOS 16.1, *)
class SidebarViewModel: ObservableObject {
    
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
                return "Directory"
            case .status:
                return "StatusLog"
            case .saved:
                return "Saved"
            case .weblog:
                return "Weblog"
            case .comingSoon:
                return "Coming Soon"
            }
        }
    }
    
    var groups: [Group] { 
        [.directory]
    }
    
    func content(in group: Group) -> [NavigationColumn] {
        switch group {
        case .directory:
            return [
                .search,
                .community,
                .garden
            ]
        default:
            return [
            ]
        }
    }
}
