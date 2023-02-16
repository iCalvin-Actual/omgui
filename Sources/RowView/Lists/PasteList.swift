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
    var fetcher: PasteListFetcher
    
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

class PasteListFetcher: ObservableObject {
    
    var addresses: [AddressModel]
    
    @Published
    var pastes: [PasteModel]
    
    init(addresses: [AddressModel] = [], pastes: [PasteModel] = []) {
        self.addresses = addresses
        self.pastes = pastes
        fetch()
    }
        
    func fetch() {
        // If no addresses, fetch from public log
        if addresses.isEmpty {
            pastes = [
                .sample
            ]
        } else {
            pastes = [
                .sample
            ]
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.pastes.append(.sample)
        }
    }
}

extension PasteModel {
    static var sample: PasteModel {
        .init(
            owner: "calvin",
            name: "Some",
            content: "Some Paste Content that could be pretty long"
        )
    }
}
