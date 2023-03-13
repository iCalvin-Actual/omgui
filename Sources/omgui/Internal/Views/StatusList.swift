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
        ListView(
            context: context,
            filters: .everyone,
            dataFetcher: fetcher,
            rowBuilder: statusView(_:)
        )
    }
    
    @ViewBuilder
    func statusView(_ status: StatusModel) -> StatusView {
        StatusView(model: status, context: context)
    }
}
