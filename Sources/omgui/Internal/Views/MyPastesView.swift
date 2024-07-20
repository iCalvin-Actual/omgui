

import SwiftUI

struct MyPastesView: View {
    
    @SceneStorage("app.lol.addresses.mine.filter")
    var filter: FilterOption = .none
    @SceneStorage("app.lol.address")
    var actingAddress: AddressName = ""
    
    @ObservedObject
    var account: AccountModel
    @ObservedObject
    var addressFetcher: AddressPasteBinDataFetcher
    
    let singleAddressMode: Bool
    
    var accountFetcher: AccountPastesDataFetcher {
        account.accountPastesFetcher
    }
    
    var activeFetcher: ListDataFetcher<PasteResponse> {
        guard !singleAddressMode else {
            return addressFetcher
        }
        switch filter {
        case .mine:
            return addressFetcher
        default:
            return accountFetcher
        }
    }
    
    init(
        singleAddress: Bool,
        addressBook: AddressBook,
        accountModel: AccountModel
    ) {
        singleAddressMode = singleAddress
        account = accountModel
        addressFetcher = addressBook.fetchConstructor.addressPastesFetcher(addressBook.actingAddress, credential: accountModel.credential(for: addressBook.actingAddress, in: addressBook))
    }
    
    var body: some View {
        ListView<PasteResponse, PasteRowView, EmptyView>(dataFetcher: activeFetcher, rowBuilder: { .init(model: $0) })
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
