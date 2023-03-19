//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/10/23.
//

import SwiftUI

struct DestinationConstructor {
    let addressBook: AddressBook
    let accountModel: AccountModel
    let fetchConstructor: FetchConstructor
    
    @ViewBuilder
    func destination(_ destination: NavigationDestination? = nil) -> some View {
        let destination = destination ?? .community
        switch destination {
        case .directory:
            DirectoryView(dataFetcher: addressBook.directoryFetcher)
        case .lists:
            AddressBookView(
                addressBook: addressBook,
                accountModel: accountModel
            )
        case .community:
            StatusList(fetcher: addressBook.statusLogFetcher, context: .column)
        case .address(let name):
            AddressSummaryView(addressSummaryFetcher: addressBook.addressSummary(name), context: .profile)
        case .webpage(let name):
            AddressProfileView(fetcher: addressBook.addressSummary(name).profileFetcher)
        case .now(let name):
            AddressNowView(fetcher: addressBook.addressSummary(name).nowFetcher)
        case .blocked:
            ListView<AddressModel, ListRow<AddressModel>, EmptyView>(filters: .none, dataFetcher: addressBook.constructBlocklist(), rowBuilder: { _ in return nil as ListRow<AddressModel>? })
        case .following:
            FollowingView(addressBook)
        case .followingAddresses:
            if let fetcher = addressBook.followingFetcher {
                ListView<AddressModel, ListRow<AddressModel>, EmptyView>(filters: .none, dataFetcher: fetcher, rowBuilder: { _ in return nil as ListRow<AddressModel>? })
            }
        case .followingStatuses:
            if let fetcher = addressBook.followingStatusLogFetcher {
                StatusList(fetcher: fetcher, context: .column)
            }
        case .addressFollowing(let name):
            ListView<AddressModel, ListRow<AddressModel>, EmptyView>(filters: .none, dataFetcher: fetchConstructor.followingFetcher(for: name, credential: accountModel.credential(for: name, in: addressBook)), rowBuilder: { _ in return nil as ListRow<AddressModel>? })
        case .nowGarden:
            GardenView(fetcher: addressBook.gardenFetcher)
        case .pastebin(let address):
            ListView<PasteModel, ListRow<PasteModel>, EmptyView>(filters: .none, dataFetcher: addressBook.addressSummary(address).pasteFetcher, rowBuilder: { _ in return nil as ListRow<PasteModel>? })
        case .purls(let address):
            ListView<PURLModel, ListRow<PURLModel>, EmptyView>(filters: .none, dataFetcher: addressBook.addressSummary(address).purlFetcher, rowBuilder: { _ in return nil as ListRow<PURLModel>? })
        case .statusLog(let address):
            StatusList(fetcher: addressBook.addressSummary(address).statusFetcher, context: .profile)
        default:
            EmptyView()
        }
    }
}
