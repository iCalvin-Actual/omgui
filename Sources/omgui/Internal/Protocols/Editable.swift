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

extension PURLModel: Editable {
    var editingDestination: NavigationDestination {
        .editPURL(addressName, title: value)
    }
}

extension PasteModel: Editable {
    var editingDestination: NavigationDestination {
        .editPaste(owner, title: name)
    }
}

extension StatusResponse: Editable {
    var editingDestination: NavigationDestination {
        .editStatus(address, id: id)
    }
}
