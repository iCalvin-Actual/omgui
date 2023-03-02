import SwiftUI

@available(iOS 16.1, *)
public struct CoreNavigationView: View {
    
    @EnvironmentObject
    var appModel: AppModel
    
    @StateObject
    var model: SceneModel = .init()
    
    @SceneStorage("scene.sort.address")
    var addressSort: Sort = .alphabet
    
    @SceneStorage("scene.active")
    var activeAddress: AddressModel?
    
    @State
    var selectedRowView: NavigationColumn? = .search
    @State
    var selectedDetail: NavigationDetailView? = .empty
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    init() {
        UITableViewCell.appearance().selectionStyle = .none
    }
    
    public var body: some View {
        VStack {
            switch horizontalSizeClass {
            case .regular:
                NavigationSplitView(
                    sidebar: sidebar,
                    content: { contentView(for: selectedRowView) },
                    detail: { detailView(for: NavigationDetailView.empty) }
                )
            default:
                TabView {
                    NavigationView {
                        contentView(for: .search)
                    }
                    .tabItem { 
                        Label(NavigationColumn.search.displayString, systemImage: NavigationColumn.search.iconName)
                    }
                    
                    NavigationView {
                        contentView(for: .community)
                    }
                    .tabItem { 
                        Label(NavigationColumn.community.displayString, systemImage: NavigationColumn.community.iconName)
                    }
                    
                    NavigationView {
                        contentView(for: .garden)
                    }
                    .tabItem { 
                        Label(NavigationColumn.garden.displayString, systemImage: NavigationColumn.garden.iconName)
                    }
                    
                    NavigationView {
                        contentView(for: .following)
                    }
                    .tabItem { 
                        Label(NavigationColumn.following.displayString, systemImage: NavigationColumn.following.iconName)
                    }
                    
                    NavigationView {
                        contentView(for: .search)
                    }
                    .tabItem { 
                        Label(NavigationColumn.search.displayString, systemImage: NavigationColumn.search.iconName)
                    }
                }
            }
        }
        .sheet(
            isPresented: $model.showAccount,
            onDismiss: { },
            content: { ManageAccountView(show: $model.showAccount).environmentObject(appModel) }
        )
        .sheet(
            isPresented: $model.showingSettings,
            onDismiss: { },
            content: { Text("Settings") }
        )
        .environmentObject(model)
        .accentColor(.lolAccent)
    }
    
    func internalAccountView() -> AccountBar? {
        guard horizontalSizeClass != .compact else {
            return nil
        }
        return AccountBar()
    }
    
    @ViewBuilder
    func sidebar() -> some View {
        AppSidebar(
            appModel: appModel,
            selected: $selectedRowView,
            accountViewBuilder: internalAccountView
        )
        .navigationDestination(for: NavigationColumn.self, destination: contentView(for:))
    }
    
    @ViewBuilder
    func contentView(for content: NavigationColumn? = nil) -> some View {
        innerRowView(for: content ?? .community)
            .navigationDestination(for: NavigationDetailView.self, destination: detailView(for:))
    }
    
    @ViewBuilder
    func innerRowView(for content: NavigationColumn?) -> some View {
        switch content {
        case .search:
            AddressListView(
                model: .init(
                    sort: addressSort,
                    filters: .everyone
                ),
                fetcher: appModel.fetchConstructor.addressDirectoryDataFetcher(),
                selected: $model.selectedAddress,
                sort: $addressSort
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("omg.lol")
                        .font(.title)
                        .fontDesign(.serif)
                        .bold()
                        .foregroundColor(.accentColor)
                }
            })
        case .community:
            StatusList(
                model: .init(
                    sort: .newestFirst,
                    filters: .everyone
                ),
                fetcher: appModel.fetchConstructor.generalStatusLog(),
                selected: $model.selectedStatus
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("status.log")
                        .font(.title)
                        .fontDesign(.serif)
                        .bold()
                        .foregroundColor(.accentColor)
                }
            })
        case .following:
            StatusList(
                model: .init(
                    sort: addressSort,
                    filters: .followed
                ),
                fetcher: appModel.fetchConstructor.statusLog(for: appModel.accountModel.following),
                selected: $model.selectedStatus
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("following.app.lol")
                        .font(.title)
                        .fontDesign(.serif)
                        .bold()
                        .foregroundColor(.accentColor)
                }
            })
        case .garden:
            NowList(
                model: .init(
                    sort: addressSort,
                    filters: .everyone
                ), 
                fetcher: appModel.fetchConstructor.nowGardenFetcher(),
                selected: $model.selectedNow,
                sort: $addressSort
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("now.lol/garden")
                        .font(.title)
                        .fontDesign(.serif)
                        .bold()
                        .foregroundColor(.accentColor)
                }
            })
        case .pinned(let address):
            ProfileView(
                model: appModel.addressDetails(address),
                context: .column
            )
        default:
            Text("NONE")
        }
    }
    
    @ViewBuilder
    func detailView(for detail: NavigationDetailView?) -> some View {
        NavigationStack {
            innerDetail(for: detail ?? selectedDetail)
        }
    }
    
    @ViewBuilder
    func innerDetail(for detail: NavigationDetailView?) -> some View {
        if let detail = detail {
            switch detail {
            case .profile(let address):
                ProfileView(
                    model: appModel.addressDetails(address),
                    context: .profile
                )
            case .now(let address):
                NowContentView(model: appModel.fetchConstructor.addresNowFetcher(address))
            default:
                ProfileView(
                    model: appModel.addressDetails("app"),
                    context: .profile
                )
            }
        } else {
            Text("NIL")
        }
    }
}
