//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/16/23.
//

import SwiftUI

struct AccountView: View {
    
    @ObservedObject
    var accountModel: AccountModel
    
    var body: some View {
        appropriateBody
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    ThemedTextView(text: "account.lol")
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
        VStack {
            Text("Welcome \(accountModel.displayName)")
            Button {
                // Show Login
                accountModel.logout()
            } label: {
                Label("Logout", systemImage: "lock")
            }
        }
    }
}
