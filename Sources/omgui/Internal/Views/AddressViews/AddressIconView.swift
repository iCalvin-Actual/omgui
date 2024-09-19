
import SwiftUI


struct AddressIconView: View {
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    let address: AddressName
    let size: CGFloat
    
    let showMenu: Bool
    
    let menuBuilder = ContextMenuBuilder<AddressModel>()
    
    init(address: AddressName, size: CGFloat = 42.0, showMenu: Bool = true) {
        self.address = address
        self.size = size
        self.showMenu = showMenu
    }
    
    var body: some View {
        if showMenu {
            menu
        } else {
            iconView
        }
    }
    
    @ViewBuilder
    var menu: some View {
        Menu {
            menuBuilder.contextMenu(for: .init(name: address), sceneModel: sceneModel)
        } label: {
            AsyncImage(url: address.addressIconURL) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                if let data = sceneModel.addressSummary(address).iconFetcher.result?.data, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Color.lolRandom(address)
                }
            }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    @ViewBuilder
    var iconView: some View {
        AsyncImage(url: address.addressIconURL) { image in
            image.resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            if let data = sceneModel.addressSummary(address).iconFetcher.result?.data, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color.lolRandom(address)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
