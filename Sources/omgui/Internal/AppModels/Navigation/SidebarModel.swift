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
    
    let addressBook: AddressBook
    
    var requests: [AnyCancellable] = []
    
    var actingAddress: AddressName {
        addressBook.actingAddress
    }
    
    init(_ addressBook: AddressBook) {
        self.addressBook = addressBook
        
        addressBook.objectWillChange.sink { _ in
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
        .store(in: &requests)
    }
    
    var sections: [Section] {
        [.directory, .status]
    }
    
    func items(for section: Section) -> [NavigationItem] {
        switch section {
        case .directory:
            var destinations = [
                NavigationItem.search,
                NavigationItem.nowGarden
            ]
            if addressBook.accountModel.signedIn {
                destinations.append(.followingAddresses)
            }
            if !addressBook.viewableBlocklist.isEmpty {
                destinations.append(.blocked)
            }
            destinations.append(contentsOf: addressBook.pinned.sorted().map({ .pinnedAddress($0) }))
            return destinations
        case .account:
            return [
            ]
        case .status:
            var destinations = [
                NavigationItem.community
            ]
            if addressBook.accountModel.signedIn {
                destinations.append(.following)
            }
            return destinations
        default:
            return []
        }
    }
}
