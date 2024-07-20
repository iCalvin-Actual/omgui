//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftData
import SwiftUI

struct AddressSummaryView: View {
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    @ObservedObject
    var addressSummaryFetcher: AddressSummaryDataFetcher
    
    var allowEditing: Bool
    
    @State
    var sidebarVisibility: NavigationSplitViewVisibility = .all
    @State
    var expandBio: Bool = false
    
    @SceneStorage("app.lol.address.page")
    var selectedPage: AddressContent = .profile
    
    let address: AddressName
    
    @Query
    var models: [AddressBioModel]
    var bio: AddressBioModel? {
        models.first(where: { $0.address == address })
    }
    
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
            .onAppear {
                Task {
                    try await sceneModel.fetchBio(address)
                }
            }
    }
    
    @ViewBuilder
    var sizeAppropriateBody: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Menu {
                    AddressModel(name: addressSummaryFetcher.addressName).contextMenu(in: sceneModel)
                } label: {
                    AddressIconView(address: addressSummaryFetcher.addressName)
                }
                .frame(width: 44)
                if let bio {
                    AddressBioLabel(expanded: $expandBio, bio: bio)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Spacer()
                }
            }
            .padding()
            
            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    ScrollView(.horizontal) {
                        HStack(alignment: .bottom, spacing: 0) {
                            ForEach(allPages) { page in
                                Button(action: {
                                    withAnimation {
                                        expandBio = false
                                        selectedPage = page
                                    }
                                }) {
                                    Text(page.displayString)
                                }
                                .buttonStyle(AddressTabStyle(isActive: selectedPage == page))
                                .background(Color.lolBackground)
                            }
                        }
                    }
                }
                .frame(height: 50)
                .ignoresSafeArea(.container, edges: [.bottom])
                
                
                destination(selectedPage)
                    .frame(maxHeight: expandBio ? 0 : .infinity)
            }
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
}

struct AddressBioLabel: View {
    @Binding
    var expanded: Bool
    
    var bio: AddressBioModel
    
    var body: some View {
        contentView(bio.bio)
            .onTapGesture {
                withAnimation {
                    expanded.toggle()
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
