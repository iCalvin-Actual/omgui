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
            DirectoryView()
//        case .community:
//            CommunityView()
//        case .address(let name):
//            AddressSummaryView(address: name)
//        case .webpage(let name):
//            AddressProfileView(address: name)
//        case .now(let name):
//            AddressNowView(address: name)
//        case .blocked:
//            BlockedView(targetAddress: .autoUpdatingAddress)
//        case .following:
//            FollowingLogView()
//        case .followingAddresses:
//            FollowingView(targetAddress: .autoUpdatingAddress)
//        case .followingStatuses:
//            StatusList(addresses: sceneModel.myAddresses)
//        case .addressFollowing(let name):
//            FollowingView(targetAddress: name)
//        case .nowGarden:
//            GardenView()
//        case .pastebin(let address):
//            AddressPasteView(address: address)
//        case .purls(let address):
//            AddressPURLsView(address: address)
//        case .purl(let address, title: let title):
//            PURLView(address: address, title: title)
//        case .paste(let address, title: let title):
//            PasteView(address: address, title: title)
//        case .statusLog(let address):
//            StatusList(addresses: [address])
//        case .status(_, id: let id):
//            StatusView(statusID: id)
//        case .account:
//            AccountView()
//        case .myStatuses:
//            MyStatusesView(singleAddressMode: false)
//        case .myPURLs:
//            MyPURLsView(singleAddressMode: false)
//        case .myPastes:
//            MyPastesView(singleAddressMode: false)
//        case .addressStatuses:
//            MyStatusesView(singleAddressMode: true)
//        case .addressPURLs:
//            MyPURLsView(singleAddressMode: true)
//        case .addressPastes:
//            MyPastesView(singleAddressMode: true)
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
        default:
            EmptyView()
        }
    }
}
