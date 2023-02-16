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
    var fetcher: PURLListFetcher
    
    @Binding
    var selected: PURLModel?
    @Binding
    var sort: Sort
    
    var context: Context = .column
    
    @EnvironmentObject
    var sceneModel: SceneModel
    
    var body: some View {
        BlockList<PURLModel, ListItem<PURLModel>>(
            model: model,
            modelBuilder: { fetcher.purls },
            rowBuilder: { _ in nil as ListItem<PURLModel>? },
            selected: $selected,
            context: context,
            sort: $sort
        )
    }
}

class PURLListFetcher: ObservableObject {
    
    var addresses: [AddressModel]
    
    @Published
    var purls: [PURLModel]
    
    init(addresses: [AddressModel] = [], purls: [PURLModel] = []) {
        self.addresses = addresses
        self.purls = purls
        fetch()
    }
        
    func fetch() {
        // If no addresses, fetch from public log
        if addresses.isEmpty {
            purls = [
                .sample
            ]
        } else {
            purls = [
                .sample
            ]
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.purls.append(.sample)
        }
    }
}

extension PURLModel {
    static var sample: PURLModel {
        .init(
            owner: "calvin",
            destination: "https://daringfireball.net",
            value: "url"
        )
    }
}
