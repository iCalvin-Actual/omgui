//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/10/23.
//

import SwiftUI

struct DestinationConstructor {
    let appModel: AppModel
    
    @ViewBuilder
    func destination(_ destination: NavigationDestination? = nil) -> some View {
        let destination = destination ?? .community
        switch destination {
        case .directory:
            DirectoryView(dataFetcher: appModel.fetchConstructor.addressDirectoryDataFetcher())
        case .community:
            StatusList(fetcher: appModel.fetchConstructor.generalStatusLog(), context: .column)
        case .address(let name):
            AddressSummaryView(addressSummaryFetcher: appModel.fetchConstructor.addressDetailsFetcher(name), context: .profile)
        case .webpage(let name):
            AddressProfileView(fetcher: appModel.fetchConstructor.addressDetailsFetcher(name).profileFetcher)
        case .now(let name):
            AddressNowView(fetcher: appModel.fetchConstructor.addressDetailsFetcher(name).nowFetcher)
        default:
            EmptyView()
        }
    }
}
