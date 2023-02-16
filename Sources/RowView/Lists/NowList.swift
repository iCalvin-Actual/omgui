//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 2/10/23.
//

import SwiftUI
import Foundation

@available(iOS 16.1, *)
struct NowList: View {
    var model: ListModel<NowModel>
    
    @ObservedObject
    var fetcher: NowListFetcher
    
    @Binding
    var selected: NowModel?
    @Binding
    var sort: Sort
    
    var context: Context = .column
    
    var body: some View {
        BlockList<NowModel, ListItem<NowModel>>(
            model: model,
            modelBuilder: { fetcher.statuses},
            rowBuilder: { _ in nil as ListItem<NowModel>? },
            selected: $selected,
            context: context,
            sort: $sort
        )
    }
}

class NowListFetcher: ObservableObject {
    static let community: NowListFetcher = .init()
    
    var addresses: [AddressModel]
    
    @Published
    var statuses: [NowModel]
    
    init(addresses: [AddressModel] = [], statuses: [NowModel] = []) {
        self.addresses = addresses
        self.statuses = statuses
        fetch()
    }
        
    func fetch() {
        // If no addresses, fetch from public log
        if addresses.isEmpty {
            statuses = [
                .calvin,
                .app
            ]
        } else {
            statuses = [
                .app
            ]
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.statuses.append(.merlin)
        }
    }
}
