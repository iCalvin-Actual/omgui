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
    
    let filters: [FilterOption]
    
    var menuBuilder: ContextMenuBuilder<StatusModel>?
    
    var body: some View {
        ModelBackedListView<StatusModel, StatusRowView, EmptyView>(
            filters: .everyone,
            dataFetcher: fetcher,
            rowBuilder: { StatusRowView(model: $0) }
        )
        .toolbarRole(.editor)
    }
}

#Preview {
    let sceneModel = SceneModel.sample
    
    StatusList(fetcher: .init(addressBook: sceneModel.addressBook, interface: sceneModel.interface, db: sceneModel.database), filters: .everyone)
        .environment(sceneModel)
}
