//
//  SwiftUIView.swift
//  
//
//  Created by Calvin Chestnut on 6/9/24.
//

import SwiftUI

struct AddressSelector: View {
    
    @Binding
    var sidebarModel: SidebarModel
    
    var body: some View {
        if sidebarModel.addressBook.accountModel.signedIn {
            activeAddressRow
                .padding()
        } else {
            Button {
                DispatchQueue.main.async {
                    Task {
                        await sidebarModel.addressBook.accountModel.authenticate()
                    }
                }
            } label: {
                Label {
                    Text("sgn in")
                } icon: {
                    Image("prami", bundle: .module)
                        .resizable()
                        .frame(width: 33, height: 33)
                }
            }
            .bold()
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.lolRandom())
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    var activeAddressRow: some View {
        ListRow<AddressModel>(
            model: .init(name: sidebarModel.actingAddress),
            preferredStyle: .minimal
        )
    }
}
