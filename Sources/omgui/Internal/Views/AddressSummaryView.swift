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
    }
    
    @ViewBuilder
    var sizeAppropriateBody: some View {
        VStack(spacing: -3) {
            HStack(alignment: .bottom) {
                ScrollView(.horizontal) {
                    HStack(alignment: .bottom, spacing: 0) {
                        ForEach(allPages) { page in
                            Button(action: {
                                withAnimation {
                                    selectedPage = page
                                }
                            }) {
                                Text(page.displayString)
                                    .font(.subheadline)
                                    .fontDesign(.rounded)
                                    .bold()
                                    .padding(8)
                                    .padding(.bottom, 6)
                                    .frame(minWidth: 44, maxHeight: .infinity, alignment: .bottom)
                                    .background(selectedPage == page ? Color.accentColor : Color.clear)
                                    .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 12, topTrailing: 12), style: .circular))
                            }
                            .buttonStyle(AddressTabStyle(isActive: selectedPage == page))
                        }
                        .padding(.horizontal, 6)
                    }
                }
                Menu {
                    AddressModel(name: addressSummaryFetcher.addressName).contextMenu(in: sceneModel)
                } label: {
                    AsyncImage(url: addressSummaryFetcher.addressName.addressIconURL) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.lolRandom(addressSummaryFetcher.addressName)
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding([.trailing, .bottom], 6)
            }
            .frame(height: 50)
            
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
