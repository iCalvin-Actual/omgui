//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/16/23.
//

import SwiftUI


struct AddressBookView: View {
    @EnvironmentObject
    var sceneModel: SceneModel
    
    @State
    var selected: AddressModel?
    
    enum ListType: RawRepresentable, Hashable, Identifiable {
        var id: String { rawValue }
        
        case directory
        case following
        case blocked
        case pinned
        case custom(name: String)
        
        init?(rawValue: String) {
            let splitString = rawValue.components(separatedBy: ".")
            switch splitString.first {
            case "directory":
                self = .directory
            case "following":
                self = .following
            case "blocked":
                self = .blocked
            case "pinned":
                self = .pinned
            case "named":
                guard splitString.count > 1 else {
                    return nil
                }
                self = .custom(name: splitString[1])
            default:
                return nil
            }
        }
        
        var rawValue: String {
            switch self {
            case .directory:                return "directory"
            case .pinned:                   return "pinned"
            case .following:                return "following"
            case .blocked:                  return "blocked"
            case .custom(name: let name):   return "named.\(name)"
            }
        }
    }
    
    var allSections: [ListType] {
        [.pinned, .directory]
    }
    
    @ObservedObject
    var pinnedFetcher: ListDataFetcher<AddressModel>
    @ObservedObject
    var blockedFetcher: ListDataFetcher<AddressModel>
    @ObservedObject
    var followedFetcher: ListDataFetcher<AddressModel>
    @ObservedObject
    var directoryFetcher: ListDataFetcher<AddressModel>
    
    func modelForList(_ list: ListType) -> ListDataFetcher<AddressModel> {
        switch list {
        case .pinned:
            return pinnedFetcher
        case .blocked:
            return blockedFetcher
        case .following:
            return followedFetcher
        case .directory:
            return directoryFetcher
        default:
            return directoryFetcher
        }
    }
    
    var activeFetcher: ListDataFetcher<AddressModel> {
        if pinnedFetcher.listItems.count > 0 {
            return pinnedFetcher
        }
        if followedFetcher.listItems.count > 0 {
            return followedFetcher
        }
        return directoryFetcher
    }
    
    var body: some View {
        ListView(
            allowSearch: false,
            dataFetcher: activeFetcher,
            rowBuilder: { _ in return nil as ListRow<AddressModel>? },
            headerBuilder: {
                Group {
                    Spacer()
                    NavigationItem.search.sidebarView
                    if !sceneModel.actingAddress.isEmpty {
                        NavigationItem.following.sidebarView
                    }
                    if sceneModel.nonGlobalBlocked.isEmpty {
                        NavigationItem.blocked.sidebarView
                    }
                }
            }
        )
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                ThemedTextView(text: "app.lol")
            }
        }
    }
}
