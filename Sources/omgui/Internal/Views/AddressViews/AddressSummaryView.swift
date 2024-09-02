//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct AddressSummaryView: View {
    @SceneStorage("app.lol.address.page")
    var selectedPage: AddressContent = .profile
    
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    @State
    var expandBio: Bool = false
    
    @ObservedObject
    var addressSummaryFetcher: AddressSummaryDataFetcher
    
    private var allPages: [AddressContent] {
        [
            .profile,
            .now,
            .statuslog,
            .pastebin,
            .purl
        ]
    }
    
    var body: some View {
        sizeAppropriateBody
            .onChange(of: sceneModel.addressBook.actingAddress) { oldValue, newValue in
                if addressSummaryFetcher.addressName.isEmpty {
                    addressSummaryFetcher.configure(name: newValue)
                }
            }
            .task { [addressSummaryFetcher] in
                await addressSummaryFetcher.perform()
            }
    }
    
    @ViewBuilder
    var addressHeader: some View {
        HStack(alignment: .top) {
            Menu {
                AddressModel(name: addressSummaryFetcher.addressName).contextMenu(in: sceneModel)
            } label: {
                AddressIconView(address: addressSummaryFetcher.addressName)
            }
            .frame(width: 44)
            AddressBioLabel(expanded: $expandBio, addressBioFetcher: addressSummaryFetcher.bioFetcher)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder
    var destinationPicker: some View {
        HStack(alignment: .top) {
            ScrollView(.horizontal) {
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(allPages) { page in
                        destinationButton(page)
                    }
                }
                .background(Color.lolBackground)
            }
        }
        .frame(height: 50)
        .ignoresSafeArea(.container, edges: [.bottom])
    }
    
    @ViewBuilder
    func destinationButton(_ page: AddressContent) -> some View {
        Button(action: {
            withAnimation {
                expandBio = false
                selectedPage = page
            }
        }) {
            Text(page.displayString)
                .bold()
                .padding(8)
                .padding(.bottom, 6)
                .frame(minWidth: 44, maxHeight: .infinity, alignment: .bottom)
                .background(page == selectedPage ? page.color : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(6)
                .foregroundColor(page == selectedPage ? .white : .primary)
                .bold(page == selectedPage)
        }
    }
    
    @ViewBuilder
    var sizeAppropriateBody: some View {
        VStack(spacing: 0) {
            addressHeader.padding()
            destinationPicker
            destination(selectedPage)
                .frame(maxHeight: expandBio ? 0 : .infinity)
        }
    }
    
    @ViewBuilder
    func destination(_ item: AddressContent? = nil) -> some View {
        let workingItem = item ?? .profile
        sceneModel.destinationConstructor.destination(workingItem.destination(addressSummaryFetcher.addressName))
            .ignoresSafeArea(.container, edges: [.bottom])
            .navigationSplitViewColumnWidth(min: 250, ideal: 600)
            .navigationBarTitleDisplayMode(.inline)
    }
    
    func fetcherForContent(_ content: AddressContent) -> Request {
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

struct AddressBioLabel: View {
    @Binding
    var expanded: Bool
    
    @ObservedObject
    var addressBioFetcher: AddressBioDataFetcher
    
    var body: some View {
        if addressBioFetcher.loading {
            LoadingView(.horizontal)
        } else if let bio = addressBioFetcher.bio?.bio {
            contentView(bio)
                .onTapGesture {
                    withAnimation {
                        expanded.toggle()
                    }
                }
        } else {
            LoadingView()
                .task { [addressBioFetcher] in
                    await addressBioFetcher.perform()
                }
        }
    }
    
    @ViewBuilder
    func contentView(_ bio: String) -> some View {
        if expanded {
            ScrollView {
                MarkdownContentView(content: bio)
            }
        } else {
            Text(bio)
                .lineLimit(3)
                .font(.caption)
                .fontDesign(.monospaced)
        }
    }
}
