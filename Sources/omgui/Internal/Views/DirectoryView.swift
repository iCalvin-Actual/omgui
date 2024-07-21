//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/12/23.
//

import SwiftData
import SwiftUI

struct DirectoryView: View {
    @Environment(SceneModel.self)
    var sceneModel
    @Query
    var names: [AddressNameModel]
    
    var body: some View {
        ListView<AddressNameModel, ListRow, EmptyView>(
            filters: .everyone,
            data: names,
            rowBuilder: { _ in return nil as ListRow<AddressNameModel>?}
        ).onAppear {
            Task {
                try await sceneModel.fetchDirectory()
            }
        }
    }
}
