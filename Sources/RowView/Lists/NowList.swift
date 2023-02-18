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
    
    @EnvironmentObject
    var appModel: AppModel
    
    var model: ListModel<NowListing>
    
    @Binding
    var selected: NowListing?
    @Binding
    var sort: Sort
    
    var context: Context = .column
    
    @ObservedObject
    var fetcher: NowGardenDataFetcher
    
    init(model: ListModel<NowListing>, fetcher: NowGardenDataFetcher, selected: Binding<NowListing?>, sort: Binding<Sort>) {
        self.model = model
        self._selected = selected
        self._sort = sort
        self.fetcher = fetcher
    }
    
    var body: some View {
        BlockList<NowListing, ListItem<NowListing>>(
            model: model,
            modelBuilder: { fetcher.gerden },
            rowBuilder: { _ in nil as ListItem<NowListing>? },
            selected: $selected,
            context: context,
            sort: $sort
        )
    }
}

struct NowContentView: View {
    let model: AddressNowDataFetcher?
    
    var body: some View {
        MarkdownTextView(model?.content ?? "")
    }
} 
