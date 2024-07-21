

import SwiftData
import SwiftUI

struct MyPastesView: View {
    
    @SceneStorage("app.lol.addresses.mine.filter")
    var filter: FilterOption = .none
    @SceneStorage("app.lol.address")
    var actingAddress: AddressName = ""
    
    @Environment(SceneModel.self)
    var sceneModel
    
    @Query
    var pastes: [AddressPasteModel]
    var filteredPastes: [AddressPasteModel] {
        pastes.filter { model in
            switch filter {
            case .mine:
                return model.owner == actingAddress
            default:
                return sceneModel.accountModel.myAddresses.contains(model.owner)
            }
        }
    }
    
    let singleAddressMode: Bool
    
    var body: some View {
        ListView<AddressPasteModel, PasteRowView, EmptyView>(data: filteredPastes, rowBuilder: { .init(model: $0) })
            .safeAreaInset(edge: .bottom, content: {
                HStack {
                    if !singleAddressMode {
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
                    }
                    Spacer()
                    NavigationLink(value: NavigationDestination.paste(actingAddress, title: "")) {
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
