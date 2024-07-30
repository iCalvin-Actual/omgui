
import SwiftUI


struct AddressIconView: View {
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    let address: AddressName
    
    var body: some View {
        AsyncImage(url: address.addressIconURL) { image in
            image.resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            if let data = sceneModel.addressBook.addressSummary(address).iconFetcher.result?.data, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color.lolRandom(address)
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
