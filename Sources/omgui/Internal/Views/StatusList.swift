//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftData
import SwiftUI

struct StatusList: View {
    
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    @Environment(\.horizontalSizeClass)
    var sizeClass
    
    @State
    var queryString: String = ""
    @State
    var sort: Sort = .alphabet
    
    @Query
    var statuses: [StatusModel]
    var filteredStatuses: [StatusModel] {
        guard let addresses else {
            return statuses
        }
        return statuses.filter { model in
            addresses.contains(model.address)
        }
    }
    
    let filters: [FilterOption] = []
    
    let addresses: [AddressName]?
    
    var menuBuilder: ContextMenuBuilder<StatusModel>?
    
    var body: some View {
        ListView<StatusModel, StatusRowView, EmptyView>(data: filteredStatuses, rowBuilder: { StatusRowView(model: $0) })
            .toolbarRole(.editor)
            .onAppear {
                Task {
                    if let addresses {
                        try await sceneModel.fetchStatuses(addresses)
                    } else {
                        try await sceneModel.fetchStatusLog()
                    }
                }
            }
    }
}
