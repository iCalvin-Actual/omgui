//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import Combine
import Foundation
import SwiftUI

@MainActor
class SidebarModel: ObservableObject {
    enum Section: String, Identifiable {
        var id: String { rawValue }
        
        case account
        case directory
        case now
        case status
        case saved
        case weblog
        case comingSoon
        case more
        case new
        
        var displayName: String {
            switch self {
            case .account:      return "my account"
            case .directory:    return "address book"
            case .now:          return "/now pages"
            case .status:       return "status.lol"
            case .saved:        return "cache.app.lol"
            case .weblog:       return "blog.app.lol"
            case .comingSoon:   return "Coming Soon"
            case .more:         return "/more"
            case .new:          return "New"
            }
        }
    }
    
    let sceneModel: SceneModel
    
    var sections: [Section] {
        var sections: [Section] = [.status, .directory, .now]
        
        if sceneModel.signedIn {
            sections.append(.more)
        }
        
        return sections
    }
    
    init(sceneModel: SceneModel) {
        self.sceneModel = sceneModel
    }
    
    func items(for section: Section) -> [NavigationItem] {
        switch section {
            
        case .directory:
            var destinations: [NavigationItem] = [.search, .blocked]
            if sceneModel.signedIn {
                destinations.insert(.following(.autoUpdatingAddress), at: 1)
            }
            destinations.append(
                contentsOf: sceneModel.pinned.sorted().map({ .pinnedAddress($0) })
            )
            return destinations
            
        case .now:
            let destinations = [
                NavigationItem.nowGarden
            ]
            return destinations
            
        case .status:
            var destinations = [
                NavigationItem.community
            ]
            if sceneModel.signedIn {
                destinations.insert(contentsOf: [.newStatus, .following(.autoUpdatingAddress)], at: 0)
            }
            return destinations
            
        default:
            return []
            
        }
    }
}
