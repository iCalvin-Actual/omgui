import SwiftUI

struct AddressImageModel {
    let addressModel: AddressModel
    
    var imageData: Data?
    
    init(_ address: AddressModel, imageData: Data?) {
        self.addressModel = address
        self.imageData = imageData
    }
}

