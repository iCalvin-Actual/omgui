//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import Combine
import SwiftUI

struct StatusList: View {
    @ObservedObject
    var fetcher: StatusLogDataFetcher
    
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    @Environment(\.horizontalSizeClass)
    var sizeClass
    
    @State
    var queryString: String = ""
    @State
    var sort: Sort = .alphabet
    
    let filters: [FilterOption] = []
    
    let addresses: [AddressName]
    
    var menuBuilder: ContextMenuBuilder<StatusResponse>?
    
    var body: some View {
        ListView<StatusResponse, StatusRowView, EmptyView>(dataFetcher: fetcher, rowBuilder: { StatusRowView(model: $0) })
            .toolbarRole(.editor)
            .onAppear {
                Task {
                    try await sceneModel.fetchStatuses(addresses)
                }
            }
    }
}
