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
            case .account:
                return "my account"
            case .directory:
                return "address book"
            case .now:
                return "/now pages"
            case .status:
                return "status.lol"
            case .saved:
                return "cache.app.lol"
            case .weblog:
                return "blog.app.lol"
            case .comingSoon:
                return "Coming Soon"
            case .more:
                return "/more"
            case .new:
                return "New"
            }
        }
    }
    
    var requests: [AnyCancellable] = []
    
    let sceneModel: SceneModel
    
    init(sceneModel: SceneModel) {
        self.sceneModel = sceneModel
    }
    
    var sections: [Section] {
        var sections: [Section] = [.status, .directory, .now]
        
        if sceneModel.signedIn {
            sections.append(.more)
        }
        
        return sections
    }
    
    func items(for section: Section) -> [NavigationItem] {
        switch section {
        case .directory:
            var destinations: [NavigationItem] = [.search]
            if sceneModel.signedIn {
                destinations.append(.editProfile)
                destinations.append(.followingAddresses)
            }
            if !sceneModel.viewableBlocklist.isEmpty {
                destinations.append(.blocked)
            }
            destinations.append(contentsOf: sceneModel.pinnedAddresses.sorted().map({ .pinnedAddress($0) }))
            return destinations
        case .now:
            var destinations = [
                NavigationItem.nowGarden
            ]
            if sceneModel.signedIn {
                destinations.insert(.editNow, at: 0)
            }
            // Handle pinned
            return destinations
        case .status:
            var destinations = [
                NavigationItem.community
            ]
            if sceneModel.signedIn {
                destinations.insert(contentsOf: [.newStatus, .myStatuses, .following], at: 0)
            }
            return destinations
        case .more:
            return [
                .myPURLs,
                .myPastes
            ]
        default:
            return []
        }
    }
}
