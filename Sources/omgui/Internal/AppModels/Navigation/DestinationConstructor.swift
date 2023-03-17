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
                addressBookModel: sceneModel.addressBook,
                accountModel: appModel.accountModel
            )
        case .directory:
            DirectoryView(dataFetcher: sceneModel.addressBook.directoryFetcher)
        case .community:
            StatusList(fetcher: fetchConstructor.generalStatusLog(), context: .column)
        case .address(let name):
            AddressSummaryView(addressSummaryFetcher: fetchConstructor.addressDetailsFetcher(name), context: .profile)
        case .webpage(let name):
            AddressProfileView(fetcher: fetchConstructor.addressDetailsFetcher(name).profileFetcher)
        case .now(let name):
            AddressNowView(fetcher: appModel.fetchConstructor.addressDetailsFetcher(name).nowFetcher)
        case .blocked:
            ListView<AddressModel, ListRow<AddressModel>, EmptyView>(filters: .none, dataFetcher: sceneModel.addressBook.blockFetcher, rowBuilder: { _ in return nil as ListRow<AddressModel>? })
        case .following:
            FollowingView(appModel.fetchConstructor.followingFetcher(for: sceneModel.actingAddress))
        case .addressFollowing(let name):
            ListView<AddressModel, ListRow<AddressModel>, EmptyView>(filters: .none, dataFetcher: appModel.fetchConstructor.followingFetcher(for: name), rowBuilder: { _ in return nil as ListRow<AddressModel>? })
        case .nowGarden:
            GardenView(fetcher: appModel.fetchConstructor.nowGardenFetcher())
        case .account:
            AccountView(accountModel: appModel.accountModel)
        case .pastebin(let address):
            ListView<PasteModel, ListRow<PasteModel>, EmptyView>(filters: .none, dataFetcher: appModel.addressDetails(address).pasteFetcher, rowBuilder: { _ in return nil as ListRow<PasteModel>? })
        case .purls(let address):
            ListView<PURLModel, ListRow<PURLModel>, EmptyView>(filters: .none, dataFetcher: appModel.addressDetails(address).purlFetcher, rowBuilder: { _ in return nil as ListRow<PURLModel>? })
        case .statusLog(let address):
            StatusList(fetcher: appModel.addressDetails(address).statusFetcher, context: .profile)
        default:
            EmptyView()
        }
    }
}
