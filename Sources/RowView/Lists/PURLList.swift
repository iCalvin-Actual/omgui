//
//  File.swift
//
//
//  Created by Calvin Chestnut on 2/9/23.
//

import SwiftUI
import Foundation

@available(iOS 16.1, *)
struct PURLList: View {
    var model: ListModel<PURLModel>
    
    @ObservedObject
    var fetcher: AddressPURLsDataFetcher
    
    @Binding
    var selected: PURLModel?
    @Binding
    var sort: Sort
    
    var context: Context = .profile
    
    @EnvironmentObject
    var sceneModel: SceneModel
    
    var body: some View {
        BlockList<PURLModel, PURLView>(
            model: model,
            dataFetcher: fetcher,
            rowBuilder: purlView(_:),
            selected: $selected,
            context: context,
            sort: $sort
        )
    }
    
    func purlView(_ model: PURLModel) -> PURLView {
        PURLView(model: model, context: context)
    }
}
