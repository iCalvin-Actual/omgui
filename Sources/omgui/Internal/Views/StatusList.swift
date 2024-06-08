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
    
    @EnvironmentObject
    var sceneModel: SceneModel
    @Environment(\.horizontalSizeClass)
    var sizeClass
    
    @State
    var queryString: String = ""
    @State
    var sort: Sort = .alphabet
    
    let filters: [FilterOption] = []
    
    var menuBuilder: ContextMenuBuilder<StatusModel>?
    
    let context: ViewContext
    
    var body: some View {
        ListView<StatusModel, StatusRowView, EmptyView>(dataFetcher: fetcher, rowBuilder: { StatusRowView(model: $0, context: context) })
            .toolbarRole(.editor)
    }
}
