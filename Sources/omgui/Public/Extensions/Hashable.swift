//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 8/2/24.
//

import Foundation

extension PURLModel {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(owner)
        hasher.combine(name)
        hasher.combine(content)
        hasher.combine(listed)
    }
}

extension PasteModel {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(owner)
        hasher.combine(name)
        hasher.combine(content)
        hasher.combine(listed)
    }
}
