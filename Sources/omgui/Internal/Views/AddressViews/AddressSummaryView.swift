//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

struct AddressSummaryView: View {
    @State
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
            .environment(\.viewContext, .profile)
            .onChange(of: sceneModel.addressBook.actingAddress.wrappedValue) { oldValue, newValue in
                if addressSummaryFetcher.addressName.isEmpty {
                    addressSummaryFetcher.configure(name: newValue)
                }
            }
            .task { [addressSummaryFetcher] in
                await addressSummaryFetcher.perform()
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
            }
        }
        .frame(maxHeight: 44)
        .padding(.vertical, 4)
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
                .font(.callout)
                .bold()
                .padding(8)
                .frame(minWidth: 44, maxHeight: .infinity, alignment: .bottom)
                .background(page == selectedPage ? Color(UIColor.systemBackground).opacity(0.42) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(6)
                .bold(page == selectedPage)
        }
    }
    
    @ViewBuilder
    var sizeAppropriateBody: some View {
        VStack(spacing: 0) {
            AddressSummaryHeader(expandBio: $expandBio, addressBioFetcher: addressSummaryFetcher.bioFetcher)
                .padding()
            destinationPicker
            destination(selectedPage)
                .frame(maxHeight: expandBio ? 0 : .infinity)
        }
    }
    
    @ViewBuilder
    func destination(_ item: AddressContent? = nil) -> some View {
        let workingItem = item ?? .profile
        sceneModel.destinationConstructor.destination(workingItem.destination(addressSummaryFetcher.addressName))
            .background(Color.clear)
            .ignoresSafeArea(.container, edges: (horizontalSizeClass == .regular && UIDevice.current.userInterfaceIdiom == .pad) ? [.bottom] : [])
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
    @Environment(\.viewContext)
    var context
    
    @Binding
    var expanded: Bool
    
    @ObservedObject
    var addressBioFetcher: AddressBioDataFetcher
    
    var body: some View {
        if addressBioFetcher.loading {
            LoadingView(.horizontal)
        } else if let bio = addressBioFetcher.bio {
            if let content = bio.bio, !content.isEmpty {
                contentView(content)
                    .onTapGesture {
                        withAnimation {
                            expanded.toggle()
                        }
                    }
            } else if context != .profile {
                AddressNameView(addressBioFetcher.address)
            } else {
                Spacer()
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
                .font(.callout)
                .fontDesign(.rounded)
        }
    }
}

struct AddressSummaryHeader: View {
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    @Binding
    var expandBio: Bool
    
    @ObservedObject
    var addressBioFetcher: AddressBioDataFetcher
    
    var body: some View {
        HStack(alignment: .top) {
            AddressIconView(address: addressBioFetcher.address)
            
            AddressBioLabel(expanded: $expandBio, addressBioFetcher: addressBioFetcher)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}
