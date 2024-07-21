//
//  File.swift
//
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftData
import SwiftUI

struct AddressSummaryView: View {
    @SceneStorage("app.lol.address.page")
    var selectedPage: AddressContent = .profile
    
    @Environment(\.horizontalSizeClass)
    var horizontalSizeClass
    
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    let address: AddressName
    
    @State
    var expandBio: Bool = false
    
    @Query
    var models: [AddressBioModel]
    var bio: AddressBioModel? {
        models.first(where: { $0.address == address })
    }
    
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
                    Text("Context menu")
//                    AddressModel(name: addressSummaryFetcher.addressName).contextMenu(in: sceneModel)
                } label: {
                    AddressIconView(address: address)
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
                .frame(height: 50)
                
                destination(selectedPage)
                    .frame(maxHeight: expandBio ? 0 : .infinity)
                    .ignoresSafeArea(.container, edges: [.bottom])
            }
        }
    }
    
    @ViewBuilder
    func destination(_ item: AddressContent? = nil) -> some View {
        let workingItem = item ?? .profile
        sceneModel.destinationConstructor.destination(workingItem.destination(address))
            .ignoresSafeArea(.container, edges: [.bottom, .leading, .trailing])
            .navigationSplitViewColumnWidth(min: 250, ideal: 600)
            .navigationBarTitleDisplayMode(.inline)
    }
}
