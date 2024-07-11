//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Foundation

extension DateFormatter {
    @MainActor
    static let storage: ISO8601DateFormatter = ISO8601DateFormatter()
    static let short: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = .autoupdatingCurrent
        return formatter
    }()
    static let medium: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    static let monthYear: DateFormatter = {
        var formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMM yy")
        return formatter
    }()
}

extension RelativeDateTimeFormatter {
    @MainActor 
    static let standard: RelativeDateTimeFormatter = {
        var formatter = RelativeDateTimeFormatter()
        
        formatter.unitsStyle = .short
        
        return formatter
    }()
}
