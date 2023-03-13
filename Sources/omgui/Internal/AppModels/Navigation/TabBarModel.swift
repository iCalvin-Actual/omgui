//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import Foundation

struct TabBarModel {
    var tabs: [NavigationItem] {
        [
            .search,
            .community,
            .blocked,
            .following,
            .nowGarden,
            .account(false)
        ]
    }
}
