
import SwiftData
import SwiftUI


struct AddressIconView: View {
    @Environment(SceneModel.self)
    var sceneModel: SceneModel
    
    let address: AddressName
    
    @Query
    var icons: [AddressIconModel]
    var icon: AddressIconModel? {
        icons.first(where: { $0.owner == address })
    }
    
    var body: some View {
        imageBody
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .onAppear {
                guard icon == nil else {
                    return
                }
                Task {
                    try await sceneModel.fetchIcon(address)
                }
            }
    }
    
    @ViewBuilder
    var imageBody: some View {
        if let data = icon?.imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            Color.lolRandom(address)
        }
    }
}
