//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/16/23.
//

import Combine
import SwiftUI

struct AccountView: View {
    @EnvironmentObject
    var sceneModel: SceneModel
    
    @ObservedObject
    var accountModel: AccountModel
    
    @State
    var selected: AddressModel? = nil
    
    var requests: [AnyCancellable] = []
    
    var menuBuilder: ContextMenuBuilder<AddressModel> = .init()
    
    var body: some View {
        appropriateBody
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    ThemedTextView(text: "Hello \(accountModel.displayName)")
                }
            }
    }
    
    @ViewBuilder
    var appropriateBody: some View {
        switch accountModel.signedIn {
        case false:
            loggedOutView
        case true:
            loggedInView
        }
    }
    
    @ViewBuilder
    var loggedOutView: some View {
        Button {
            // Show Login
            DispatchQueue.main.async {
                Task {
                    await accountModel.authenticate()
                }
            }
        } label: {
            Label("Login", systemImage: "lock.open")
        }
    }
    
    @ViewBuilder
    var loggedInView: some View {
        VStack(alignment: .leading) {
            if let fetcher = sceneModel.addressBook.myAddressesFetcher, let address = sceneModel.addressBook.address {
                
                ThemedTextView(text: "using \(address.addressDisplayString)", font: .headline)
                    .padding(.horizontal)
                
                List(selection: $selected) {
                    Section {
                        ForEach(fetcher.listItems) { item in
                            ZStack(alignment: .leading) {
                                Button {
                                    self.selected = item
                                } label: {
                                    EmptyView()
                                }
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Spacer()
                                        
                                        Text(item.listTitle)
                                            .font(.title)
                                            .bold()
                                            .foregroundColor(.black)
                                            .padding(.bottom, 8)
                                            .padding(.trailing, 4)
                                        
                                        Spacer()
                                    }
                                    Spacer()
                                    if item == self.selected {
                                        Image(systemName: "checkmark")
                                            .resizable()
                                            .frame(width: 22, height: 22)
                                            .padding()
                                            .padding(.trailing)
                                    }
                                }
                                .padding(.vertical)
                                .padding(.leading, 32)
                                .background(Color.lolRandom(item))
                                .cornerRadius(24)
                                .fontDesign(.serif)
                            }
                            .listRowSeparator(.hidden, edges: .all)
                            .contextMenu(menuItems: {
                                self.menuBuilder.contextMenu(for: item, with: sceneModel)
                            })
                        }
                    } header: {
                        Text("my addresses")
                    }
                }
                .refreshable(action: {
                    await fetcher.update()
                })
                .listStyle(.plain)
                .navigationBarTitleDisplayMode(.inline)
            }
            Button {
                // Show Login
                accountModel.logout()
            } label: {
                HStack {
                    Spacer()
                    Label("Logout", systemImage: "lock")
                        .padding()
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
    }
}
