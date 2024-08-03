//
//  SwiftUIView.swift
//
//
//  Created by Calvin Chestnut on 5/2/23.
//

import SwiftUI

struct AccountView: View {
    @SceneStorage("app.lol.address")
    var actingAddress: AddressName = ""
    
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    @State
    var searchAddress: String = ""
    @State
    var presentUpsell: Bool = false
    
    var availabilityText: String {
        "Enter an address to check availability"
    }
    
    var body: some View {
        NavigationStack {
            if sceneModel.signedIn {
                AddressSummaryView(
                    selectedPage: .profile,
                    addressSummaryFetcher: sceneModel.addressSummary(sceneModel.actingAddress)
                )
            } else {
                ScrollView {
                    signedOutHeader
                    
                    VStack(alignment: .leading) {
                        Text("Start here")
                            .font(.caption2)
                            .fontDesign(.monospaced)
                            .foregroundColor(.lolPurple)
                            .brightness(-0.5)
                        TextField("Search Address", text: $searchAddress, prompt: Text("Type your name"))
                            .padding(6)
                            .background(Color.white)
                            .cornerRadius(8)
                        Text(availabilityText)
                            .font(.caption)
                            .foregroundColor(.lolPurple)
                            .brightness(-0.5)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.lolPurple)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Group {
                                Text("Already have an address on")
                                +
                                Text(" omg.lol")
                                    .foregroundColor(.lolPink)
                                +
                                Text("?")
                            }
                            .bold()
                            .multilineTextAlignment(.leading)
                            .font(.title2)
                            .fontDesign(.serif)
                            .foregroundColor(.black)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        
                        HStack {
                            Button {
                                sceneModel.authenticate()
                            } label: {
                                Text("Sign in with omg.lol")
                                    .bold()
                                    .font(.callout)
                                    .fontDesign(.serif)
                                    .padding(3)
                            }
                            .accentColor(.lolPink)
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.roundedRectangle(radius: 6))
                            Spacer()
                        }
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.lolBlue)
                    
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Group {
                                Text("Learn more about ")
                                    .foregroundColor(.black)
                                +
                                Text("omg.lol")
                                    .foregroundColor(.lolPink)
                            }
                            .bold()
                            .multilineTextAlignment(.leading)
                            .font(.title2)
                            .fontDesign(.serif)
                            .foregroundColor(.black)
                            
                            Spacer()
                            
                            Image(systemName: "tree.fill")
                                .resizable()
                                .frame(width: 88, height: 88)
                                .foregroundColor(.lolGreen)
                                .brightness(-0.5)
                                .padding([.top, .trailing], 4)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Text("The best way to build your presence on the open web.")
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.headline)
                            .fontDesign(Font.Design.monospaced)
                            .foregroundColor(.black)
                        
                        HStack {
                            Link(destination: URL(string: "https://home.omg.lol/referred-by/app")!) {
                                Text("Discover")
                                    .bold()
                                    .font(.callout)
                                    .fontDesign(.serif)
                                    .padding(3)
                            }
                            .accentColor(.lolPink)
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.roundedRectangle(radius: 6))
                            Spacer()
                        }
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.lolGreen)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Group {
                                Text("The complete experience, on-the-go, with ")
                                +
                                Text("app.lol++")
                                    .foregroundColor(.lolPink)
                            }
                            .bold()
                            .multilineTextAlignment(.leading)
                            .font(.title2)
                            .fontDesign(.serif)
                            .foregroundColor(.black)
                            
                            Spacer()
                            
                            Image(systemName: "app.badge.fill")
                                .resizable()
                                .frame(width: 88, height: 88)
                                .foregroundColor(.lolOrange)
                                .brightness(-0.5)
                                .padding([.top, .trailing], 4)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Text("Follow addresses, find new friends. Take the experience further with plus-plus.")
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.headline)
                            .fontDesign(Font.Design.monospaced)
                            .foregroundColor(.black)
                        
                        HStack {
                            Button {
                                presentUpsell = true
                            } label: {
                                Text("app.lol ++")
                                    .bold()
                                    .font(.callout)
                                    .fontDesign(.serif)
                                    .padding(3)
                            }
                            .accentColor(.lolPink)
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.roundedRectangle(radius: 6))
                            Spacer()
                        }
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.lolOrange)
                    .padding(.bottom, 24)
                }
                .toolbar(content: {
                    ToolbarItem(placement: .topBarLeading) {
                        ThemedTextView(text: "omg.lol?")
                    }
                })
            }
        }
        .environment(\.viewContext, ViewContext.detail)
        .sheet(isPresented: $presentUpsell) {
            UpsellView()
        }
    }
    
    @ViewBuilder
    var signedOutHeader: some View {
        VStack(alignment: .leading) {
            Text("Looking for the best internet address you've ever had?")
                .multilineTextAlignment(.center)
                .font(.title)
                .bold()
                .fontDesign(.serif)
                .foregroundColor(colorScheme == .dark ? .lolYellow : .lolTeal)
                .padding()
                .frame(maxWidth: .infinity)
            
            HStack {
                Text("Web Page")
                    .foregroundColor(.lolPink)
                Spacer()
                Text("Email Address")
                    .foregroundColor(.lolGreen)
                Spacer()
                Text("PasteBin")
                    .foregroundColor(.lolTeal)
                Spacer()
                Text("PURLs")
                    .foregroundColor(.lolBlue)
                Spacer()
                Text("StatusLog")
                    .foregroundColor(.lolPurple)
            }
            .bold()
            .dynamicTypeSize(.xSmall ... .xLarge)
            .font(.caption)
            .padding(.horizontal, 4)
        }
    }
}