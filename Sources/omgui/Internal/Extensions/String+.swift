//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import Foundation

extension Optional<String> {
    var boolValue: Bool {
        self?.boolValue ?? false
    }
}

extension String {
    var boolValue: Bool {
        switch self.lowercased() {
        case "true", "t", "yes", "y":
            return true
        case "false", "f", "no", "n", "":
            return false
        default:
            if let int = Int(self) {
                return int != 0
            }
            return false
        }
    }
}
