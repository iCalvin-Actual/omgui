//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 7/29/24.
//

import SwiftUI


public extension PresentationDetent {
    static let draftDrawer: PresentationDetent = .fraction(0.25)
}
extension PresentationDetent: @retroactive Identifiable {
    public var id: Int {
        hashValue
    }
}
