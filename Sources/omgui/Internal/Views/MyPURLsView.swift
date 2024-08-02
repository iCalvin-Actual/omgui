

import SwiftUI

struct MyPURLsView: View {
    
    @Environment(SceneModel.self)
    var scene
    
    @SceneStorage("app.lol.addresses.mine.filter")
    var filter: FilterOption = .none
    @ObservedObject
    var addressFetcher: AddressPURLsDataFetcher
    
    let singleAddressMode: Bool
    
    init(singleAddress: Bool, injectedScene: SceneModel) {
        singleAddressMode = singleAddress
        addressFetcher = injectedScene.fetchConstructor.addressPURLsFetcher(injectedScene.actingAddress, credential: injectedScene.credential(for: injectedScene.actingAddress))
    }
    
    var body: some View {
        ModelBackedListView<PURLModel, PURLRowView, EmptyView>(dataFetcher: addressFetcher, rowBuilder: { .init(model: $0) })
            .safeAreaInset(edge: .bottom, content: {
                HStack {
                    Button(action: toggleFilter) {
                        ZStack(alignment: .bottom) {
                            Image(systemName: "person.3")
                                .opacity(filter != .mine ? 1 : 0)
                            Image(systemName: "person.fill")
                                .scaleEffect(filter == .mine ? 1 : 1.1)
                                .padding(.bottom, 2)
                        }
                        .bold()
                        .foregroundStyle(Color.white)
                        .frame(width: 44, height: 44)
                        .padding(8)
                        .background(Color.lolAccent)
                        .mask(Circle())
                    }
                    Spacer()
                    NavigationLink(value: NavigationDestination.purl(scene.actingAddress, title: "")) {
                        Image(systemName: "pencil.and.scribble")
                            .bold()
                            .foregroundStyle(Color.white)
                            .frame(width: 44, height: 44)
                            .padding(8)
                            .background(Color.lolAccent)
                            .mask(Circle())
                    }
                }
                .font(.headline)
                .padding(.horizontal)
            })
    }
    
    private func toggleFilter() {
        withAnimation {
            switch filter {
            case .mine:
                filter = .none
            default:
                filter = .mine
            }
        }
    }
}
