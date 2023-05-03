//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 5/2/23.
//

import SwiftUI

struct AccountView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State
    var searchAddress: String = ""
    
    var availabilityText: String {
        "Enter an address to check availability"
    }
    
    @ViewBuilder
    var header: some View {
        VStack(alignment: .leading) {
            Text("Looking for the best internet address you've ever had?")
                .multilineTextAlignment(.center)
                .font(.title)
                .bold()
                .fontDesign(.serif)
                .foregroundColor(colorScheme == .dark ? .lolYellow : .lolTeal)
                .frame(maxWidth: .infinity)
            
            HStack {
                Text("Web Page")
                    .foregroundColor(.lolPink)
                Spacer()
                Text("Email Address")
                    .foregroundColor(.lolYellow)
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
            .dynamicTypeSize(.xSmall ... .xLarge)
            .font(.caption)
            .padding(.top)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 44) {
                header
                
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
                
                StandardCard(
                    titleText: Text("Already have an address on")
                    +
                    Text(" omg.lol")
                        .foregroundColor(.lolPink)
                    +
                    Text("?"),
                    buttonText: Text("Sign in with omg.lol"),
                    color: .lolBlue) {
                        print("Sign in")
                    }
                
                StandardCard(
                    titleText: Text("Learn more about ")
                        .foregroundColor(.black)
                    +
                    Text("omg.lol")
                        .foregroundColor(.lolPink),
                    bodyText: Text("The best way to build your presence on the open web."), iconName: "tree.fill",
                    buttonText: Text("Sign in with omg.lol"),
                    color: .lolGreen) {
                        print("Sign in")
                    }
                
                StandardCard(
                    titleText: Text("Manage on the go with ")
                        .foregroundColor(.black)
                    +
                    Text("app.lol")
                        .foregroundColor(.lolPink),
                    bodyText: Text("Follow addresses, find new friends. Take the experience further with plus-plus."),
                    iconName: "app.badge.fill",
                    buttonText: Text("app.lol ++"),
                    color: .lolOrange) {
                        print("Sign in")
                    }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .background(Color.lolBackground)
    }
}

struct StandardCard: View {
    var titleText: Text?
    var bodyText: Text?
    var iconName: String?
    var buttonText: Text?
    var color: Color = .lolRandom()
    var buttonAction: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                titleText?
                    .bold()
                    .multilineTextAlignment(.leading)
                    .font(.title2)
                    .fontDesign(.serif)
                    .foregroundColor(.black)
                
                Spacer()
                
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .resizable()
                        .frame(width: 88, height: 88)
                        .foregroundColor(color)
                        .brightness(-0.5)
                        .padding([.top, .trailing], 4)
                }
            }
            .frame(maxWidth: .infinity)
            
            bodyText?
                .fixedSize(horizontal: false, vertical: true)
                .font(.headline)
                .fontDesign(Font.Design.monospaced)
                .foregroundColor(.black)
            
            HStack {
                Button {
                    buttonAction?()
                } label: {
                    buttonText?
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
        .background(color)
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AccountView()
        }
    }
}
