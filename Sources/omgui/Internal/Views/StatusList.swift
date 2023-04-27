//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct StatusList: View {
    @ObservedObject
    var fetcher: StatusLogDataFetcher
    
    let context: ViewContext
    
    var body: some View {
        ListView<StatusModel, StatusRowView, EmptyView>(
            context: context,
            filters: .everyone,
            dataFetcher: fetcher,
            rowBuilder: statusView(_:)
        )
    }
    
    @ViewBuilder
    func statusView(_ status: StatusModel) -> StatusRowView {
        StatusRowView(model: status, context: context)
    }
}
