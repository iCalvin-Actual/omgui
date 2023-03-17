//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import Combine
import Foundation

class SidebarModel: ObservableObject {
    enum Section: String, Identifiable {
        var id: String { rawValue }
        
        case account
        case directory
        case status
        case saved
        case weblog
        case comingSoon
        
        var displayName: String {
            switch self {
            case .account:
                return "my account"
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
    
    let sceneModel: SceneModel
    var appModel: AppModel {
        sceneModel.appModel
    }
    
    var requests: [AnyCancellable] = []
    
    init(sceneModel: SceneModel) {
        self.sceneModel = sceneModel
        sceneModel.appModel.objectWillChange.sink { _ in
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
        .store(in: &requests)
    }
    
    var sections: [Section] {
        [.directory, .status, .saved, .account]
    }
    
    func items(for section: Section) -> [NavigationItem] {
        switch section {
        case .directory:
            return [
                .search,
                .nowGarden,
            ]
        case .account:
            var destinations = [
                NavigationItem.account(!appModel.accountModel.actingAddress.isEmpty)
            ]
            if !sceneModel.addressBook.nonGlobalBlocklist.isEmpty {
                destinations.append(.blocked)
            }
            return destinations
        case .status:
            var destinations = [
                NavigationItem.community
            ]
            if appModel.accountModel.signedIn {
                destinations.append(.following)
            }
            return destinations
        case .saved:
            return sceneModel.addressBook.pinnedItems.map({ $0.name }).sorted().map({ .pinnedAddress($0) })
        default:
            return []
        }
    }
}
