//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 2/9/23.
//

import SwiftUI
import Foundation

@available(iOS 16.1, *)
struct StatusList: View {
    var model: ListModel<StatusModel>
    
    @ObservedObject
    var fetcher: StatusListFetcher
    
    @Binding
    var selected: StatusModel?
    @Binding
    var sort: Sort
    
    var context: Context = .column
    
    @EnvironmentObject
    var sceneModel: SceneModel
    
    var body: some View {
        BlockList<StatusModel, StatusView>(
            model: model,
            modelBuilder: { fetcher.statuses},
            rowBuilder: statusView(_:),
            selected: $selected,
            context: context,
            sort: $sort
        )
    }
    
    @ViewBuilder
    func statusView(_ status: StatusModel) -> StatusView {
        StatusView(model: status, context: context)
    }
}

class StatusListFetcher: ObservableObject {
    static let community: StatusListFetcher = .init()
    
    var addresses: [AddressName]
    
    @Published
    var statuses: [StatusModel]
    
    init(addresses: [AddressName] = [], statuses: [StatusModel] = []) {
        self.addresses = addresses
        self.statuses = statuses
        fetch()
    }
        
    func fetch() {
        // If no addresses, fetch from public log
        if addresses.isEmpty {
            statuses = [
                .fromCalvin,
                .fromApp
            ]
        } else {
            statuses = [
                .fromCalvin
            ]
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.statuses.append(.fromMerlin)
        }
    }
}

extension StatusModel {
    static var fromCalvin: StatusModel {
        .init(
            id: UUID().uuidString,
            address: "calvin",
            posted: .init(timeIntervalSince1970: 20000),
            status: "Making a status",
            emoji: "🙈",
            linkText: nil,
            link: nil
        )
    }
    static var fromApp: StatusModel {
        .init(
            id: UUID().uuidString,
            address: "app",
            posted: .init(timeIntervalSince1970: 0),
            status: "Making a status",
            emoji: "🙈",
            linkText: nil,
            link: nil
        )
    }
    static var fromMerlin: StatusModel {
        .init(
            id: UUID().uuidString,
            address: "hotdogsladies",
            posted: .init(),
            status: "Making a status",
            emoji: "🙈",
            linkText: nil,
            link: nil
        )
    }
}
