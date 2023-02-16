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
    enum Context {
        case column
        case profile
    }
    
    var model: ListModel<PasteModel>
    
    @ObservedObject
    var fetcher: AddressPasteBinDataFetcher
    
    @Binding
    var selected: PasteModel?
    @Binding
    var sort: Sort
    
    var context: Context = .column
    
    @EnvironmentObject
    var sceneModel: SceneModel
    
    var body: some View {
        BlockList<PasteModel, ListItem<PasteModel>>(
            model: model,
            modelBuilder: { fetcher.pastes },
            rowBuilder: { _ in nil as ListItem<PasteModel>? },
            selected: $selected,
            context: .column,
            sort: $sort
        )
    }
    
    @ViewBuilder
    func pasteView(_ paste: PasteModel) -> PasteView {
        PasteView(model: paste)
    }
}
