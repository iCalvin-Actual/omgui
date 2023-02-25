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
        VStack {
            Image(systemName: item.icon)
                .font(.subheadline)
                .bold()
            
            Text(item.displayString)
                .font(.headline)
                .fontDesign(.serif)
        }
        .padding(8)
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
            return "PasteBin"
        case .statuslog:
            return "StatusLog"
        }
    }
    var icon: String {
        switch self {
        case .profile:
            return "person.circle"
        case .now:
            return "clock"
        case .purl:
            return "link"
        case .pastebin:
            return "list.clipboard"
        case .statuslog:
            return "bubble.left"
        }
    }
    
    func externalUrlString(for name: AddressName) -> String {
        switch self {
        case .profile:
            return "\(name).omg.lol"
        case .now:
            return "\(name).omg.lol/now"
        case .purl:
            return "\(name).url.lol"
        case .pastebin:
            return "\(name).paste.lol"
        case .statuslog:
            return "\(name).status.lol"
        }
    }
    
    var color: Color {
        switch self {
        case .profile:
            return .lolYellow
        case .now:
            return .lolGreen
        case .purl:
            return .lolTeal
        case .pastebin:
            return .lolOrange
        case .statuslog:
            return .lolPurple
        }
    }
}
