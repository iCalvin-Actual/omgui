//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/12/23.
//

import Combine
import SwiftData
import SwiftUI

struct DirectoryView: View {
    
    @Environment(SceneModel.self)
    var sceneModel
    
//    @Query
//    var names: [AddressNameModel]
    var names: [AddressNameModel] = {
        Range(uncheckedBounds: (0, 1250)).map({ _ in
            AddressNameModel(name: "adam")
        })
    }()
    
    
    
    var body: some View {
        ListView<AddressNameModel, ListRow, EmptyView>(
            filters: .everyone,
            data: names,
            rowBuilder: { _ in return nil as ListRow<AddressNameModel>?}
        )
        .onAppear {
            print("Creating names")
        }
    }
}
