

import SwiftUI

struct MyStatusesView: View {
    
    @SceneStorage("app.lol.addresses.mine.filter")
    var filter: FilterOption = .none
    @SceneStorage("app.lol.address")
    var actingAddress: AddressName = ""
    
    @ObservedObject
    var account: AccountModel
    @ObservedObject
    var addressFetcher: StatusLogDataFetcher
    
    let singleAddressMode: Bool
    
    var accountFetcher: StatusLogDataFetcher {
        account.accountStatusesFetcher
    }
    
    var activeFetcher: StatusLogDataFetcher {
        switch filter {
        case .mine:
            return addressFetcher
        default:
            return accountFetcher
        }
    }
    
    init(singleAddress: Bool, addressBook: AddressBook, accountModel: AccountModel) {
        singleAddressMode = singleAddress
        account = accountModel
        addressFetcher = addressBook.fetchConstructor.statusLog(for: [addressBook.actingAddress])
    }
    
    var body: some View {
        StatusList(fetcher: activeFetcher, addresses: singleAddressMode ? addressFetcher.addresses : accountFetcher.addresses)
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
                    NavigationLink(value: NavigationDestination.editStatus(actingAddress, id: "")) {
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
