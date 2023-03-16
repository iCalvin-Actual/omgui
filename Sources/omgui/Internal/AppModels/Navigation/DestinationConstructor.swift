//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/10/23.
//

import SwiftUI

struct DestinationConstructor {
    let sceneModel: SceneModel
    
    var appModel: AppModel { sceneModel.appModel }
    
    @ViewBuilder
    func destination(_ destination: NavigationDestination? = nil) -> some View {
        let destination = destination ?? .community
        let fetchConstructor = sceneModel.appModel.fetchConstructor
        switch destination {
        case .lists:
            AddressBookView(
                pinnedFetcher: PinnedListDataFetcher(appModel: appModel),
                blockedFetcher: BlockListDataFetcher(
                    globalFetcher: .init(address: "app", interface: appModel.interface),
                    localFetcher: LocalBlockListDataFetcher(appModel: appModel),
                    interface: appModel.interface
                ),
                followedFetcher: appModel.fetchConstructor.followingFetcher(for: sceneModel.actingAddress),
                directoryFetcher: appModel.fetchConstructor.addressDirectoryDataFetcher()
            )
        case .directory:
            DirectoryView(dataFetcher: appModel.fetchConstructor.addressDirectoryDataFetcher())
        case .community:
            StatusList(fetcher: fetchConstructor.generalStatusLog(), context: .column)
        case .address(let name):
            AddressSummaryView(addressSummaryFetcher: fetchConstructor.addressDetailsFetcher(name), context: .profile)
        case .webpage(let name):
            AddressProfileView(fetcher: fetchConstructor.addressDetailsFetcher(name).profileFetcher)
        case .now(let name):
            AddressNowView(fetcher: appModel.fetchConstructor.addressDetailsFetcher(name).nowFetcher)
        case .blocked:
            ListView<AddressModel, ListRow<AddressModel>, EmptyView>(filters: .none, dataFetcher: sceneModel.addressBookFetcher.blockedModel, rowBuilder: { _ in return nil as ListRow<AddressModel>? })
        case .following:
            FollowingView(appModel.fetchConstructor.followingFetcher(for: sceneModel.actingAddress))
        case .addressFollowing(let name):
            ListView<AddressModel, ListRow<AddressModel>, EmptyView>(filters: .none, dataFetcher: appModel.fetchConstructor.followingFetcher(for: name), rowBuilder: { _ in return nil as ListRow<AddressModel>? })
        case .nowGarden:
            GardenView(fetcher: appModel.fetchConstructor.nowGardenFetcher())
        default:
            EmptyView()
        }
    }
}
