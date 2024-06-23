//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 4/27/23.
//

import SwiftUI

struct StatusDraftView: View {
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    @ObservedObject
    var draftPoster: StatusDraftPoster
    @SceneStorage("app.lol.address")
    var actingAddress: AddressName = ""
    
    @State
    var expandAddresses: Bool = false
    
    var draftId: String {
        draftPoster.draft.id ?? ""
    }
    
    var body: some View {
        VStack(alignment: .trailing) {
            if draftId.isEmpty {
                Button {
                    withAnimation{
                        expandAddresses.toggle()
                    }
                } label: {
                    AddressNameView(actingAddress)
                        .padding(.horizontal)
                }
                if expandAddresses {
                    ForEach(sceneModel.accountModel.myAddresses) { address in
                        if address != actingAddress {
                            Button {
                                withAnimation {
                                    actingAddress = address
                                    expandAddresses = false
                                }
                            } label: {
                                AddressNameView(address)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            } else {
                // Show Address
                AddressNameView(draftPoster.address)
            }
            HStack(alignment: .top) {
                VStack {
                    Button {
                        // Show emoji picker
                    } label: {
                        Text("✨")
                            .font(.largeTitle)
                    }

                    Text("Choose an emoji")
                        .font(.caption2)
                }
                
                VStack(alignment: .trailing) {
                    TextEditor(text: $draftPoster.draft.content)
                        .frame(idealHeight: 125, maxHeight: .infinity)
                    
                    Button {
                        Task {
                            if draftId.isEmpty {
                                draftPoster.address = actingAddress
                            }
                            await draftPoster.perform()
                        }
                    } label: {
                        Text("Save")
                            .padding()
                    }
                }
            }
            .background(Material.regular)
//            .ignoresSafeArea(.
            Spacer()
        }
        .background(Color.lolBackground)
    }
}
