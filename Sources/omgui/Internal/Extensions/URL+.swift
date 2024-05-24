//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 5/23/24.
//

import Foundation

extension URL: Identifiable {
    public var id: String { absoluteString }
}
