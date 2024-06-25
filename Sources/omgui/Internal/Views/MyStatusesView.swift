

import SwiftUI

struct MyStatusesView: View {
    
    @SceneStorage("app.lol.addresses.mine.filter")
    var filter: FilterOption = .none
    
    @ObservedObject
    var account: AccountModel
    @ObservedObject
    var addressFetcher: StatusLogDataFetcher
    
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
    
    init(addressBook: AddressBook, accountModel: AccountModel) {
        account = accountModel
        addressFetcher = addressBook.fetchConstructor.statusLog(for: [addressBook.actingAddress])
    }
    
    var body: some View {
        StatusList(fetcher: activeFetcher)
//            .safeAreaPadding(.bottom, 63)
            .safeAreaInset(edge: .bottom, content: {
                Button(action: toggleFilter) {
                    ZStack(alignment: .bottom) {
                        Image(systemName: "person.3")
                            .opacity(filter != .mine ? 1 : 0)
                        Image(systemName: "person.fill")
                            .scaleEffect(filter == .mine ? 1 : 1.1)
                    }
                    .bold()
                    .foregroundStyle(Color.white)
                    .padding()
                    .background(Color.lolAccent)
                    .mask(Circle())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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
