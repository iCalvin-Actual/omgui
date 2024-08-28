//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/10/23.
//

import SwiftUI

@MainActor
struct DestinationConstructor {
    let sceneModel: SceneModel

    @ViewBuilder
    func destination(_ destination: NavigationDestination? = nil) -> some View {
        let destination = destination ?? .community
        switch destination {
        case .directory:
            DirectoryView(
                fetcher: sceneModel.directoryFetcher
            )
        case .community:
            CommunityView(sceneModel.statusFetcher)
        case .address(let name):
            AddressSummaryView(addressSummaryFetcher: sceneModel.addressSummary(name))
        case .webpage(let name):
            AddressProfileView(fetcher: sceneModel.addressSummary(name).profileFetcher)
//        case .now(let name):
//            AddressNowView(fetcher: addressBook.addressSummary(name).nowFetcher)
//        case .blocked:
//            ListView<AddressModel, ListRow<AddressModel>, EmptyView>(filters: .none, dataFetcher: addressBook.constructBlocklist(), rowBuilder: { _ in return nil as ListRow<AddressModel>? })
//        case .following:
//            FollowingView(addressBook)
//        case .followingAddresses:
//            if let fetcher = addressBook.followingFetcher {
//                ModelBackedListView<AddressModel, ListRow<AddressModel>, EmptyView>(filters: .none, dataFetcher: fetcher, rowBuilder: { _ in return nil as ListRow<AddressModel>? })
//            }
//        case .followingStatuses:
//            if let fetcher = addressBook.followingStatusLogFetcher {
//                StatusList(fetcher: fetcher)
//            }
//        case .following(let name):
//            ModelBackedListView<AddressModel, ListRow<AddressModel>, EmptyView>(filters: .none, dataFetcher: fetcher.followingFetcher(for: name, credential: accountModel.credential(for: name, in: addressBook)), rowBuilder: { _ in return nil as ListRow<AddressModel>? })
//        case .nowGarden:
//            GardenView(fetcher: addressBook.gardenFetcher)
//        case .pastebin(let address):
//            AddressPasteView(fetcher: addressBook.addressSummary(address).pasteFetcher)
//        case .purls(let address):
//            AddressPURLsView(fetcher: addressBook.addressSummary(address).purlFetcher)
//        case .purl(let address, title: let title):
//            PURLView(fetcher: fetcher.addressPURLFetcher(address, title: title, credential: accountModel.credential(for: address, in: addressBook)))
//        case .paste(let address, title: let title):
//            PasteView(fetcher: fetcher.addressPasteFetcher(address, title: title, credential: accountModel.credential(for: address, in: addressBook)))
//        case .statusLog(let address):
//            StatusList(fetcher: addressBook.addressSummary(address).statusFetcher)
//        case .status(let address, id: let id):
//            StatusView(fetcher: fetcher.statusFetcher(id, from: address))
//        case .account:
//            AccountView(addressBook: addressBook, accountModel: accountModel)
//        case .myStatuses:
//            MyStatusesView(singleAddress: false, addressBook: addressBook, accountModel: accountModel)
//        case .myPURLs:
//            MyPURLsView(singleAddress: false, addressBook: addressBook, accountModel: accountModel)
//        case .editPURL(let address, title: let title):
//            if let credential = accountModel.credential(for: address, in: addressBook) {
//                NamedItemDraftView(fetcher: fetcher.draftPurlPoster(title, for: address, credential: credential))
//            } else {
//                // Unauthorized
//                EmptyView()
//            }
//        case .myPastes:
//            MyPastesView(singleAddress: false, addressBook: addressBook, accountModel: accountModel)
//        case .editPaste(let address, title: let title):
//            if let credential = accountModel.credential(for: address, in: addressBook) {
//                NamedItemDraftView(fetcher: fetcher.draftPastePoster(title, for: address, credential: credential))
//            } else {
//                // Unauthorized
//                EmptyView()
//            }
////        case .editWebpage(let name):
////            if let poster = addressBook.profilePoster(for: name) {
////                EditPageView(poster: poster)
////            } else {
////                // Unauthenticated
////                EmptyView()
////            }
////        case .editNow(let name):
////            if let poster = addressBook.nowPoster(for: name) {
////                EditPageView(poster: poster)
////            } else {
////                // Unauthenticated
////                EmptyView()
////            }
//        case .editStatus(let address, id: let id):
//            if address == .autoUpdatingAddress && id.isEmpty {
//                StatusDraftView(draftPoster: fetcher.draftStatusPoster(for: address, credential: accountModel.authKey))
//            } else if let credential = accountModel.credential(for: address, in: addressBook) {
//                StatusDraftView(draftPoster: fetcher.draftStatusPoster(id, for: address, credential: credential))
//            } else {
//                // Unauthenticated
//                EmptyView()
//            }
//        case .addressStatuses:
//            MyStatusesView(singleAddress: true, addressBook: addressBook, accountModel: accountModel)
//        case .addressPURLs:
//            MyPURLsView(singleAddress: true, addressBook: addressBook, accountModel: accountModel)
//        case .addressPastes:
//            MyPastesView(singleAddress: true, addressBook: addressBook, accountModel: accountModel)
        default:
            EmptyView()
        }
    }
}
