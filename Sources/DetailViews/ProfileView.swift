import SwiftUI

@available(iOS 16.1, *)
struct ProfileView: View {
    @EnvironmentObject
    var sceneModel: SceneModel
    @EnvironmentObject
    var appModel: AppModel
    
    @ObservedObject
    var addressModel: AddressDetailsDataFetcher
    
    @ObservedObject
    var profileModel: AddressProfileDataFetcher
    @ObservedObject
    var nowModel: AddressNowDataFetcher
    @ObservedObject
    var statusModel: StatusLogDataFetcher
    @ObservedObject
    var pastebinModel: AddressPasteBinDataFetcher
    @ObservedObject
    var purlModel: AddressPURLsDataFetcher
    
    @State
    var sort: Sort = .newestFirst
    
    @State
    var selectedStatus: StatusModel?
    @State
    var selectedPaste: PasteModel?
    @State
    var selectedPURL: PURLModel?
    
    let context: Context
    
    @State
    var sidebarVisibility: NavigationSplitViewVisibility = .all
    
    init(model: AddressDetailsDataFetcher, selectedStatus: StatusModel? = nil, selectedPaste: PasteModel? = nil, selectedPURL: PURLModel? = nil, context: Context = .profile) {
        self.addressModel = model
        self.profileModel = model.profileFetcher
        self.nowModel = model.nowFetcher
        self.purlModel = model.purlFetcher
        self.pastebinModel = model.pasteFetcher
        self.statusModel = model.statusFetcher
        self.context = context
        
        self.sort = sort
        self.selectedStatus = selectedStatus
        self.selectedPaste = selectedPaste
        self.selectedPURL = selectedPURL
        
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Text(addressModel.addressName.addressDisplayString)
                    .font(.title)
                    .fontDesign(.serif)
                    .bold()
                Spacer()
            }
            .padding(8)
            .background(Color.blue)
            
            if context == .profile {
                NavigationSplitView(columnVisibility: $sidebarVisibility) {
                    sidebar()
                        .navigationSplitViewColumnWidth(ideal: 225, max: 420)
                } detail: {
                    destination()
                }
                .navigationSplitViewStyle(.balanced)
                .toolbarBackground(.hidden, for: .navigationBar)
            } else {
                sidebar()
            }
        }
    }
    
    @ViewBuilder
    func sidebar() -> some View {
        VStack {
            HStack(alignment: .top) {
                Text(addressModel.url?.absoluteString ?? "")
                
                Spacer()
            }
            
            Grid {
                ForEach(gridItems) { item in
                    ProfileGridView(model: item, destination: destination(_:))
                }
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    func destination(_ item: ProfileGridItem = .statuslog) -> some View {
        innerDestination(item)
            .navigationSplitViewColumnWidth(min: 250, ideal: 600)
    }
    
    @ViewBuilder
    func innerDestination(_ item: ProfileGridItem) -> some View {
        switch item {
        case .profile:
            HTMLStringView(htmlContent: profileModel.html ?? "")
        case .now:
            NowContentView(model: nowModel)
        case .statuslog:
            StatusList(
                model: .init(
                    sort: sort
                ),
                fetcher: statusModel,
                selected: $sceneModel.selectedStatus,
                sort: $sort,
                context: .profile
            )
        case .pastebin:
            PasteList(
                model: .init(
                    sort: sort
                ),
                fetcher: pastebinModel,
                selected: $sceneModel.selectedPaste,
                sort: $sort,
                context: .profile
            )
        case .purl:
            PURLList(
                model: .init(
                    sort: sort
                ),
                fetcher: purlModel,
                selected: $sceneModel.selectedPURL,
                sort: $sort,
                context: .profile
            )
        }
    }
    
    var gridItems: [ProfileGridItemModel] {
        [
            .init(
                item: .profile,
                isLoaded: true
            ),
            .init(
                item: .now,
                isLoaded: true
            ),
            .init(
                item: .statuslog,
                isLoaded: true
            ),
            .init(
                item: .purl,
                isLoaded: true
            ),
            .init(
                item: .pastebin,
                isLoaded: true
            )
        ]
    }
}
