//
//  File.swift
//
//
//  Created by Calvin Chestnut on 2/9/23.
//

import SwiftUI
import Foundation

@available(iOS 16.1, *)
struct PasteList: View {
    var model: ListModel<PasteModel>
    
    @ObservedObject
    var fetcher: AddressPasteBinDataFetcher
    
    @Binding
    var selected: PasteModel?
    @Binding
    var sort: Sort
    
    var context: Context = .profile
    
    @EnvironmentObject
    var sceneModel: SceneModel
    
    var body: some View {
        BlockList<PasteModel, PasteView>(
            model: model,
            dataFetcher: fetcher,
            rowBuilder: pasteView(_:),
            selected: $selected,
            context: .column,
            sort: $sort
        )
    }
    
    @ViewBuilder
    func pasteView(_ paste: PasteModel) -> PasteView {
        PasteView(model: paste, context: context)
    }
}
