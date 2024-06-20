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
            case .new:
                return "New"
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
        var sections: [Section] = [.status, .directory, .now]
        
        if addressBook.accountModel.signedIn {
            sections.append(.new)
        }
        
        return sections
    }
    
    func items(for section: Section) -> [NavigationItem] {
        switch section {
        case .directory:
            var destinations: [NavigationItem] = [.search]
            if addressBook.accountModel.signedIn {
                destinations.append(.editProfile)
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
            var destinations = [
                NavigationItem.nowGarden
            ]
            if addressBook.accountModel.signedIn {
                destinations.insert(.editNow, at: 0)
            }
            // Handle pinned
            return destinations
        case .status:
            var destinations = [
                NavigationItem.community
            ]
            if addressBook.accountModel.signedIn {
                destinations.insert(contentsOf: [.newStatus, .myStatuses, .following], at: 0)
            }
            return destinations
        default:
            return []
        }
    }
}
