//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftData
import SwiftUI

struct AddressStatusesView: View {
    
    @Query
    var models: [AddressBioModel]
    var bio: AddressBioModel? {
        models.first(where: { $0.address == address })
    }
    
    let address: AddressName
    
    var body: some View {
        VStack(alignment: .leading) {
            if let bio {
                AddressBioView(bio: bio)
            }
            StatusList(addresses: [address])
        }
        .toolbar {       
            ToolbarItem(placement: .topBarLeading) {
                ThemedTextView(text: address.addressDisplayString + ".statusLog")
            }
        }
    }
}
