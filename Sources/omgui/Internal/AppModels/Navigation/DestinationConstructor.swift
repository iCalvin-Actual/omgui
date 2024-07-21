//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/10/23.
//

import SwiftUI

@MainActor
struct DestinationConstructor {
    let accountModel: AccountModel
    let fetchConstructor: FetchConstructor

    @ViewBuilder
    func destination(_ destination: NavigationDestination? = nil) -> some View {
        let destination = destination ?? .community
        switch destination {
        case .directory:
            DirectoryView()
        case .community:
            CommunityView()
        case .address(let name):
            AddressSummaryView(address: name)
        case .webpage(let name):
            AddressProfileView(address: name)
        case .now(let name):
            AddressNowView(address: name)
        case .blocked:
            BlockedView(targetAddress: .autoUpdatingAddress)
        case .following:
            FollowingLogView()
        case .followingAddresses:
            FollowingView(targetAddress: .autoUpdatingAddress)
        case .followingStatuses:
            StatusList(addresses: accountModel.myAddresses)
        case .addressFollowing(let name):
            FollowingView(targetAddress: name)
        case .nowGarden:
            GardenView()
        case .pastebin(let address):
            AddressPasteView(address: address)
        case .purls(let address):
            AddressPURLsView(address: address)
        case .purl(let address, title: let title):
            PURLView(address: address, title: title)
        case .paste(let address, title: let title):
            PasteView(address: address, title: title)
        case .statusLog(let address):
            StatusList(addresses: [address])
        case .status(let address, id: let id):
            StatusView(fetcher: fetchConstructor.statusFetcher(id, from: address))
        case .account:
            AccountView()
        case .myStatuses:
            MyStatusesView(singleAddressMode: false)
        case .myPURLs:
            MyPURLsView(singleAddressMode: false)
        case .editPURL(let address, title: let title):
            if let credential = accountModel.credential(for: address) {
                NamedItemDraftView(fetcher: fetchConstructor.draftPurlPoster(title, for: address, credential: credential))
            } else {
                // Unauthorized
                EmptyView()
            }
        case .myPastes:
            MyPastesView(singleAddressMode: false)
        case .editPaste(let address, title: let title):
            if let credential = accountModel.credential(for: address) {
                NamedItemDraftView(fetcher: fetchConstructor.draftPastePoster(title, for: address, credential: credential))
            } else {
                // Unauthorized
                EmptyView()
            }
//        case .editWebpage(let name):
//            if let poster = addressBook.profilePoster(for: name) {
//                EditPageView(poster: poster)
//            } else {
//                // Unauthenticated
//                EmptyView()
//            }
//        case .editNow(let name):
//            if let poster = addressBook.nowPoster(for: name) {
//                EditPageView(poster: poster)
//            } else {
//                // Unauthenticated
//                EmptyView()
//            }
        case .editStatus(let address, id: let id):
            if address == .autoUpdatingAddress && id.isEmpty {
                StatusDraftView(draftPoster: fetchConstructor.draftStatusPoster(for: address, credential: accountModel.authKey))
            } else if let credential = accountModel.credential(for: address) {
                StatusDraftView(draftPoster: fetchConstructor.draftStatusPoster(id, for: address, credential: credential))
            } else {
                // Unauthenticated
                EmptyView()
            }
        case .addressStatuses:
            MyStatusesView(singleAddressMode: true)
        case .addressPURLs:
            MyPURLsView(singleAddressMode: true)
        case .addressPastes:
            MyPastesView(singleAddressMode: true)
        default:
            EmptyView()
        }
    }
}
