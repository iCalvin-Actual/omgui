//
//  File 2.swift
//  
//
//  Created by Calvin Chestnut on 3/15/23.
//

import SwiftUI

struct GardenView: View {
    @EnvironmentObject
    var sceneModel: SceneModel
    
    @ObservedObject
    var fetcher: NowGardenDataFetcher
    
    var body: some View {
        ListView<NowListing, ListRow<NowListing>, EmptyView>(dataFetcher: fetcher, rowBuilder: { _ in return nil as ListRow<NowListing>? })
    }
}
