import SwiftUI

public class DirectoryModel: ObservableObject {
    @Published
    var addresses: [AddressModel] = []

    func fetch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.addresses = [
                .init(
                    name: "app",
                    url: nil, 
                    registered: Date()
                ),
                .init(
                    name: "calvin",
                    url: nil,
                    registered: Date(timeIntervalSinceNow: -2000000)
                ),
                .init(
                    name: "hotdogsladies",
                    url: nil,
                    registered: Date(timeIntervalSince1970: 0)
                )
            ]
        }
    }    
}
