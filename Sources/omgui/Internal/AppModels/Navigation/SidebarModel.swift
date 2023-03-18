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
                return "address book"
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
    
    var sceneModel: SceneModel
    
    var appModel: AppModel {
        sceneModel.appModel
    }
    
    var requests: [AnyCancellable] = []
    
    init(sceneModel: SceneModel) {
        self.sceneModel = sceneModel
        sceneModel.appModel.accountModel.objectWillChange.sink { _ in
            DispatchQueue.main.async {
                Task {
                    await self.sceneModel.addressBook.update()
                }
            }
        }
        .store(in: &requests)
        sceneModel.addressBook.objectWillChange.sink { _ in
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
            var destinations = [
                NavigationItem.search,
                NavigationItem.nowGarden
            ]
            if !sceneModel.addressBook.actingAddress.isEmpty {
                destinations.append(.followingAddresses)
            }
            if !sceneModel.addressBook.nonGlobalBlocklist.isEmpty {
                destinations.append(.blocked)
            }
            return destinations
        case .account:
            var destinations: [NavigationItem] = [
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
