//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import Combine
import Foundation
import SwiftUI

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
            }
        }
    }
    
    @ObservedObject
    var addressBook: AddressBook
    
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
        [.status, .directory, .now]
    }
    
    func items(for section: Section) -> [NavigationItem] {
        switch section {
        case .directory:
            var destinations: [NavigationItem] = [.search]
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
        case .now:
            let destinations = [
                NavigationItem.nowGarden
            ]
            // Handle pinned
            return destinations
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
