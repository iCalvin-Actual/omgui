//
//  File.swift
//  omgui
//
//  Created by Calvin Chestnut on 9/11/24.
//

import SwiftUI

struct SafetyView: View {
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    @Environment(AccountAuthDataFetcher.self)
    var authFetcher: AccountAuthDataFetcher
    
    
    @ObservedObject
    var globalBlocklistFetcher: AddressBlockListDataFetcher
    @ObservedObject
    var localBlocklistFetcher: LocalBlockListDataFetcher
    @ObservedObject
    var addressBlocklistFetcher: AddressBlockListDataFetcher
    
    var menuBuilder: ContextMenuBuilder<AddressModel> = .init()
    
    @State
    var selected: AddressModel?
    
    init(addressBook: AddressBook) {
        self.globalBlocklistFetcher = addressBook.globalBlocklistFetcher
        self.localBlocklistFetcher = addressBook.localBlocklistFetcher
        self.addressBlocklistFetcher = addressBook.addressBlocklistFetcher
    }
    
    
    @ViewBuilder
    var body: some View {
        List(selection: $selected) {
            Section("reach out") {
                Text("if you need to reach out for help with another address, for any reason, do not hesitate.")
                    .multilineTextAlignment(.leading)
                ReportButton()
            }
            .foregroundStyle(.primary)
            .listRowBackground(Color(UIColor.systemBackground).opacity(0.82))
            Section("blocked") {
                if sceneModel.addressBook.visibleBlocked.isEmpty {
                    Text("If you wan't to stop seeing content from an address, Long Press the address or avatar and select Safety > Block")
                } else {
                    ForEach(sceneModel.addressBook.visibleBlocked.map({ AddressModel(name: $0) })) { item in
                        ListRow(model: item)
                            .tag(item)
                            .listRowSeparator(.hidden, edges: .all)
                            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .contextMenu(menuItems: {
                                self.menuBuilder.contextMenu(for: item, fetcher: nil, sceneModel: sceneModel)
                            }) {
                                ListRow(model: item, selected: .constant(item))
                                    .environment(sceneModel)
                                    .environment(authFetcher)
                            }
                    }
                }
            }
            .foregroundStyle(.primary)
            .listRowBackground(Color(UIColor.systemBackground).opacity(0.82))
        }
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ThemedTextView(text: "safety")
            }
        }
    }
    
    @ViewBuilder
    var visibleBlockedList: some View {
        ListView<AddressModel, EmptyView>(filters: .none, dataFetcher: sceneModel.privateSummary(for: sceneModel.addressBook.actingAddress.wrappedValue)?.blockedFetcher ?? sceneModel.addressBook.localBlocklistFetcher)
            .scrollContentBackground(.hidden)
        // Add toolbar item to insert new
    }
}

#Preview {
    let model = SceneModel.sample
    let authFetcher = AccountAuthDataFetcher(authKey: nil, client: .sample, interface: model.interface)
    SafetyView(addressBook: model.addressBook)
        .environment(model)
        .environment(authFetcher)
        .background(Gradient(colors: [.red, .orange]))
}
