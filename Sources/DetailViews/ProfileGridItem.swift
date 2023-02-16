//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 2/12/23.
//

import SwiftUI
import Foundation

@available(iOS 16.1, *)
struct ProfileGridItemModel: Hashable, Identifiable {
    
    let item: ProfileGridItem
    let isLoaded: Bool
    
    public init(item: ProfileGridItem, isLoaded: Bool) {
        self.item = item
        self.isLoaded = isLoaded
    }
    
    @ViewBuilder
    var label: some View {
        Label(item.displayString, systemImage: item.icon)
            .font(.headline)
            .fontDesign(.serif)
            .bold()
            .padding(32)
            .background(Color.green)
    }
}

enum ProfileGridItem: String, Identifiable, Codable {
    var id: String { rawValue }
    
    case profile
    case now
    case purl
    case pastebin
    case statuslog
    
    var displayString: String {
        switch self {
        case .profile:
            return "Profile"
        case .now:
            return "Now"
        case .purl:
            return "PURLs"
        case .pastebin:
            return "Pastebin"
        case .statuslog:
            return "Statuslog"
        }
    }
    var icon: String {
        return "sparkles"
    }
}
