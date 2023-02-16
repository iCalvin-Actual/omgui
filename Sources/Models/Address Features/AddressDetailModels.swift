import SwiftUI

//@MainActor
@available(iOS 16.1, *)
public class AddressDetailModels: ObservableObject {
    @Published
    var addressModel: AddressModel
    
    let statusFetcher: StatusListFetcher
    
    @Published
    var imageModel: AddressImageModel?
    var profileModel: ProfileViewModel?
    var nowModel: NowViewModel?
    var purlModel: AddressPURLModel?
    var pasteModel: AddressPasteBinModel?
    
    public init(address: AddressName) {
        self.addressModel = .init(name: address)
        self.statusFetcher = .init(addresses: [address])
        fetch()
    }
    
    private func fetch() {
        Task {
            
            // Fetch address info
            // Fetch address now
            // Fetch address purls, pastes, and statuses
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.addressModel.url = URL(string: "https://cbc.gay")
                self.addressModel.registered = Date()
                self.objectWillChange.send()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.profileModel = .init(addressModel: self.addressModel, html: "Some HTML String")
                self.objectWillChange.send()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                self.nowModel = .init(addressModel: self.addressModel, content: "Some Now Text")
                self.objectWillChange.send()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                self.purlModel = AddressPURLModel(
                    addressModel: self.addressModel, 
                    purls: [
                        .init(owner: "calvin", destination: "http://www.daringFireball.net", value: "fireball"),
                        .init(owner: "calvin", destination: "http://cbc.gay", value: "home")
                    ]
                )
                self.objectWillChange.send()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.pasteModel = AddressPasteBinModel(addressModel: self.addressModel, pastes: [
                    .init(owner: "calvin", name: "paste", content: "Some really long content I want to reuse")
                ])
                self.objectWillChange.send()
            }
        }
    }
    
    var gridItems: [ProfileGridItemModel] {
        [
            .init(
                item: .profile, 
                isLoaded: profileModel != nil
            ),
            .init(
                item: .now,
                isLoaded: nowModel != nil
            ),
            .init(
                item: .statuslog,
                isLoaded: true
            ),
            .init(
                item: .purl,
                isLoaded: purlModel != nil
            ),
            .init(
                item: .pastebin,
                isLoaded: pasteModel != nil
            )
        ]
    }
    
    var profileHTML: String {
        profileModel?.html ?? ""
    }
    
    var nowString: String {
        nowModel?.content ?? ""
    }
}

struct ProfileViewModel {
    var addressModel: AddressModel
    var html: String
}

struct NowViewModel {
    var addressModel: AddressModel
    var content: String
}

struct AddressPasteBinModel {
    let addressModel: AddressModel
    let pastes: [PasteModel]
}

struct AddressPURLModel {
    let addressModel: AddressModel
    let purls: [PURLModel]
}
