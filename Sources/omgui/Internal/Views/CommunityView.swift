//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 4/30/23.
//

import SwiftData
import SwiftUI

@MainActor
struct CommunityView: View {
    
    let addressBook: AddressBook
    
    @Query
    var models: [StatusModel]
    
    init(addressBook: AddressBook) {
        self.addressBook = addressBook
    }
    
    @State
    private var active: List = .community
    private var timeline: Timeline = .today
    
    var listLabel: String {
        switch active {
        case .community:            return "community"
        case .following(let name):  return "following from \(name.addressDisplayString)"
        case .me:                   return "my addresses"
        }
    }
    
    enum List {
        case community
        case following(AddressName)
        case me
    }
    
    enum Timeline {
        case today
        case week
        case month
        case all
    }
    
    var body: some View {
        StatusList(addresses: nil)
            .environment(\.viewContext, .column)
    }
}
