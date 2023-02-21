//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 2/9/23.
//

import SwiftUI
import Foundation

@available(iOS 16.1, *)
struct StatusList: View {
    var model: ListModel<StatusModel>
    
    @ObservedObject
    var fetcher: StatusLogDataFetcher
    
    @Binding
    var selected: StatusModel?
    @Binding
    var sort: Sort
    
    var context: Context = .column
    
    @EnvironmentObject
    var sceneModel: SceneModel
    
    var body: some View {
        BlockList<StatusModel, StatusView>(
            model: model,
            dataFetcher: fetcher,
            rowBuilder: statusView(_:),
            selected: $selected,
            context: context,
            sort: $sort
        )
    }
    
    @ViewBuilder
    func statusView(_ status: StatusModel) -> StatusView {
        StatusView(model: status, context: context)
    }
}
