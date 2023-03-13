//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Foundation

extension DateFormatter {
    static let storage: ISO8601DateFormatter = {
        return ISO8601DateFormatter()
    }()
    static let short: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let monthYear: DateFormatter = {
        var formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMM yy")
        return formatter
    }()
}
