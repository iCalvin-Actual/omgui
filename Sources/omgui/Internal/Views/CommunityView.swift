//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 4/30/23.
//

import SwiftUI

struct CommunityView: View {
    
    
    let addressBook: AddressBook
    
    let communityFetcher: StatusLogDataFetcher
    var myFetcher: StatusLogDataFetcher
    
    init(addressBook: AddressBook) {
        self.addressBook = addressBook
        self.communityFetcher = addressBook.statusLogFetcher
        self.myFetcher = addressBook.fetchConstructor.statusLog(for: addressBook.myAddresses)
    }
    
    var activeFethcer: StatusLogDataFetcher {
        switch active {
        case .community:
            return communityFetcher
        case .following:
            return addressBook.fetchConstructor.statusLog(for: addressBook.following)
        case .me:
            return myFetcher
        }
    }
    
    @State
    private var active: List = .community
    private var timeline: Timeline = .today
    
    var listLabel: String {
        switch active {
        case .community:            return "community"
        case .following(let name):  return "following from \(name.addressDisplayString)"
        case .me:                   return "my addresses"
        }
    }
    
    enum List {
        case community
        case following(AddressName)
        case me
    }
    
    enum Timeline {
        case today
        case week
        case month
        case all
    }
    
    var body: some View {
        StatusList(fetcher: communityFetcher, context: .column)
            .toolbar {
                // Check if this is appropriate to show?
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Menu {
                            if addressBook.accountModel.signedIn {
                                Button {
                                    active = .me
                                } label: {
                                    Label(title: { Text("My addresses") }, icon: { EmptyView() })
                                }
                                Section {
                                    ForEach(addressBook.myAddresses) { address in
                                        Button {
                                            active = .following(address)
                                        } label: {
                                            Label(title: { Text(address) }, icon: { EmptyView() })
                                        }
                                    }
                                } header: {
                                    Text("Followed from:")
                                }
                            }
                            Button {
                                active = .community
                            } label: {
                                Label(title: { Text("community") }, icon: { EmptyView() })
                            }
                        } label: {
                            Label(listLabel, systemImage: "chevron.down.circle")
                        }
                        Spacer()
                        Button {
                            // Change timeline
                        } label: {
                            Text("This week")
                        }
                    }
                }
            }
    }
}
