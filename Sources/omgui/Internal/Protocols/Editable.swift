//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 4/30/23.
//

import Foundation
import SwiftUI

protocol Editable: AddressManagable {
    var editingDestination: NavigationDestination { get }
}

extension AddressPURLModel: Editable {
    var editingDestination: NavigationDestination {
        .editPURL(addressName, title: title)
    }
}

extension AddressPasteModel: Editable {
    var editingDestination: NavigationDestination {
        .editPaste(owner, title: title)
    }
}

extension StatusModel: Editable {
    var editingDestination: NavigationDestination {
        .editStatus(address, id: id)
    }
}
