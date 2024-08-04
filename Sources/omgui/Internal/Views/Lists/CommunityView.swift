//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 4/30/23.
//

import SwiftUI

@MainActor
struct CommunityView: View {
    @Environment(SceneModel.self)
    var scene
    
    let communityFetcher: StatusLogDataFetcher
    var myFetcher: StatusLogDataFetcher
    
    init(_ scene: SceneModel) {
        self.communityFetcher = scene.fetcher.generalStatusLog()
        self.myFetcher = scene.fetcher.statusLog(for: scene.myAddresses)
    }
    
    var activeFethcer: StatusLogDataFetcher {
        switch active {
        case .community:
            return communityFetcher
        case .following:
            return scene.fetcher.statusLog(for: scene.following)
        case .me:
            return myFetcher
        }
    }
    
    @State
    private var active: List = .community
    private var timeline: Timeline = .today
    
    var listLabel: String {
        switch active {
        case .community:            return "community"
        case .following(let name):  return "following from \(name.addressDisplayString)"
        case .me:                   return "my addresses"
        }
    }
    
    enum List {
        case community
        case following(AddressName)
        case me
    }
    
    enum Timeline {
        case today
        case week
        case month
        case all
    }
    
    var body: some View {
        StatusList(fetcher: communityFetcher)
            .environment(\.viewContext, .column)
    }
}
