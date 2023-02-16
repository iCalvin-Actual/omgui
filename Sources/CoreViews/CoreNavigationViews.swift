import SwiftUI

@available(iOS 16.1, *)
public struct CoreNavigationView: View {
    
    @EnvironmentObject
    var model: SceneModel
    @EnvironmentObject
    var accountModel: AccountModel
    
    @SceneStorage("scene.sort.address")
    var addressSort: Sort = .alphabet
    
    @SceneStorage("scene.active")
    var activeAddress: AddressModel?
    
    @State
    var sidebarModel: SidebarViewModel = .init()
    
    @State
    var selectedRowView: NavigationColumn? = .search
    @State
    var selectedDetail: NavigationDetailView? = .empty
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    public init() {
    }
    
    public var body: some View {
        VStack {
            NavigationSplitView(
                sidebar: sidebar,
                content: { contentView(for: selectedRowView) },
                detail: { detailView(for: NavigationDetailView.empty) }
            )
            if horizontalSizeClass == .compact {
                AccountBar()
            }
        }
        .sheet(
            isPresented: $accountModel.showingAccountModal,
            onDismiss: { },
            content: { ManageAccountView() }
        )
        .sheet(
            isPresented: $model.showingSettings,
            onDismiss: { },
            content: { EmptyView() }
        )
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
            model: sidebarModel,
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
                selected: $model.selectedAddress,
                sort: $addressSort
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Directory")
                        .font(.title)
                        .fontDesign(.serif)
                        .bold()
                }
            })
        case .community:
            StatusList(
                model: .init(
                    sort: addressSort,
                    filters: .everyone
                ),
                fetcher: .community,
                selected: $model.selectedStatus,
                sort: $addressSort
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Directory")
                        .font(.title)
                        .fontDesign(.serif)
                        .bold()
                }
            })
        case .following:
            StatusList(
                model: .init(
                    sort: addressSort,
                    filters: .followed
                ),
                fetcher: .community,
                selected: $model.selectedStatus,
                sort: $addressSort
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Following")
                        .font(.title)
                        .fontDesign(.serif)
                        .bold()
                }
            })
        case .garden:
            NowList(
                model: .init(
                    sort: addressSort,
                    filters: .everyone
                ),
                fetcher: .init(),
                selected: $model.selectedNow,
                sort: $addressSort
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Now Garden")
                        .font(.title)
                        .fontDesign(.serif)
                        .bold()
                }
            })
        case .pinned(let address):
            ProfileView(
                model: AppModel.state.addressDetails(address),
                context: .column
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(address.addressDisplayString)
                        .font(.title)
                        .fontDesign(.serif)
                        .bold()
                }
            })
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
                    model: AppModel.state.addressDetails(address),
                    context: .profile
                )
            default:
                Text("EMPTY")
            }
        } else {
            Text("NIL")
        }
    }
}
