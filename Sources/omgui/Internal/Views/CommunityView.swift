//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 4/30/23.
//

import SwiftUI

struct CommunityView: View {
    
    enum List {
        case community
        case following
    }
    
    let communityFetcher: StatusLogDataFetcher
    let followingFetcher: StatusLogDataFetcher?
    
    var activeFetcher: StatusLogDataFetcher {
        if active == .following, let followingFetcher = followingFetcher {
            return followingFetcher
        }
        return communityFetcher
    }
    
    @State
    private var active: List = .following
    
    var body: some View {
        if followingFetcher != nil {
            Picker("Data source", selection: $active) {
                Text("Following").tag(List.following)
                Text("Community").tag(List.community)
            }
            .pickerStyle(.segmented)
        }
        StatusList(fetcher: activeFetcher, context: .column)
    }
}
