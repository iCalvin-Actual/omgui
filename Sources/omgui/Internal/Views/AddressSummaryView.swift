//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct AddressSummaryView: View {
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    @ObservedObject
    var addressSummaryFetcher: AddressSummaryDataFetcher
    
    var context: ViewContext
    var allowEditing: Bool
    
    @State
    var sidebarVisibility: NavigationSplitViewVisibility = .all
    
    @SceneStorage("app.lol.address.page")
    var selectedPage: AddressContent = .profile
    
    private var allPages: [AddressContent] {
        pages + more
    }
    
    private var pages: [AddressContent] {
        [
            .profile,
            .now
        ]
    }
    
    private var more: [AddressContent] {
        [
            .statuslog,
            .pastebin,
            .purl
        ]
    }
    
    var body: some View {
        sizeAppropriateBody
            .background(Color.lolBackground)
//            .onChange(of: addressSummaryFetcher) { oldValue, newValue in
//                selectedPage = .profile
//            }
    }
    
    @ViewBuilder
    var sizeAppropriateBody: some View {
        VStack(spacing: 0) {
            HStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        ForEach(allPages) { page in
                            Button(action: {
                                withAnimation {
                                    selectedPage = page
                                }
                            }) {
                                Text(page.displayString)
                                    .font(.callout)
                                    .fontDesign(.rounded)
                                    .bold()
                            }
                            .buttonStyle(AddressTabStyle(isActive: selectedPage == page))
                        }
                    }
                    .padding(.horizontal)
                }
                Menu {
                    AddressModel(name: addressSummaryFetcher.addressName).contextMenu(in: sceneModel)
                } label: {
                    AsyncImage(url: addressSummaryFetcher.profileFetcher.imageURL) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.lolRandom(addressSummaryFetcher.addressName)
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.trailing)
            }
            .frame(height: 60)
            .background(Material.bar)
            
            destination(selectedPage)
        }
    }
    
    @ViewBuilder
    func destination(_ item: AddressContent? = nil) -> some View {
        let workingItem = item ?? .profile
        sceneModel.destinationConstructor.destination(workingItem.destination(addressSummaryFetcher.addressName))
            .ignoresSafeArea(.container, edges: [.bottom, .leading, .trailing])
            .navigationSplitViewColumnWidth(min: 250, ideal: 600)
            .navigationBarTitleDisplayMode(.inline)
    }
    
    func fetcherForContent(_ content: AddressContent) -> DataFetcher {
        switch content {
        case .now:
            return addressSummaryFetcher.nowFetcher
        case .pastebin:
            return addressSummaryFetcher.pasteFetcher
        case .purl:
            return addressSummaryFetcher.purlFetcher
        case .profile:
            return addressSummaryFetcher.profileFetcher
        case .statuslog:
            return addressSummaryFetcher.statusFetcher
        }
    }
}
