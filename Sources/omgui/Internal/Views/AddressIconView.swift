
import SwiftData
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
            Color.lolRandom(address)
        }
        .frame(width: 66, height: 66)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
