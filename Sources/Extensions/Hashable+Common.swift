//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 2/12/23.
//

import Foundation

extension Hashable where Self: Identifiable {
    public var id: Int { hashValue }
}
