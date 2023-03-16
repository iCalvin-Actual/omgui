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
    
    @EnvironmentObject
    var sceneModel: SceneModel
    
    @ObservedObject
    var addressSummaryFetcher: AddressSummaryDataFetcher
    
    var context: ViewContext
    
    @State
    var sidebarVisibility: NavigationSplitViewVisibility = .all
    
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
            .navigationTitle("")
    }
    
    @ViewBuilder
    var sizeAppropriateBody: some View {
        if horizontalSizeClass == .regular && context != .column {
            NavigationSplitView(columnVisibility: $sidebarVisibility) {
                sidebar
                    .navigationSplitViewColumnWidth(ideal: 225, max: 420)
                    .navigationDestination(for: NavigationDestination.self, destination: sceneModel.destinationConstructor.destination(_:))
            } detail: {
                destination()
            }
            .navigationSplitViewStyle(.balanced)
        } else {
            sidebar
        }
    }
    
    var sidebar: some View {
        VStack {
            Grid {
                Section {
                    GridRow {
                        ForEach(pages) { item in
                            HStack {
                                Spacer()
                                AddressContentButton(contentType: item, name: addressSummaryFetcher.addressName)
                                Spacer()
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("pages")
                            .fontDesign(.monospaced)
                            .font(.subheadline)
                            .bold()
                            .padding(8)
                        Spacer()
                    }
                }
                
                Section {
                    ForEach(more) { item in
                        GridRow {
                            HStack {
                                Spacer()
                                AddressContentButton(contentType: item, name: addressSummaryFetcher.addressName)
                                Spacer()
                            }
                            .gridCellColumns(2)
                        }
                    }
                } header: {
                    HStack {
                        Text("more")
                            .fontDesign(.monospaced)
                            .font(.subheadline)
                            .bold()
                            .padding(8)
                        Spacer()
                    }
                }
            }
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                AddressNameView(addressSummaryFetcher.addressName)
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
