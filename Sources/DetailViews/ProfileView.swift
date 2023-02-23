import SwiftUI

@available(iOS 16.1, *)
struct ProfileView: View {
    @EnvironmentObject
    var sceneModel: SceneModel
    @EnvironmentObject
    var appModel: AppModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
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
    var selectedItem: ProfileGridItem = .profile
    
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
            switch context {
            case .column:
                sidebar()
            case .profile:
                switch horizontalSizeClass {
                case .regular:
                    NavigationSplitView(columnVisibility: $sidebarVisibility) {
                        sidebar()
                            .navigationSplitViewColumnWidth(ideal: 225, max: 420)
                    } detail: {
                        destination()
                    }
                    .ignoresSafeArea(.container, edges: .top)
                    .navigationSplitViewStyle(.balanced)
                    .toolbarBackground(.hidden, for: .navigationBar)
                default:
                    sidebar()                    
                }
            }
        }
        .toolbar {
            if !(horizontalSizeClass == .regular && context == .profile) {
                ToolbarItem(placement: .navigationBarLeading) { 
                    Text(addressModel.addressName.addressDisplayString)
                        .font(.title)
                        .fontDesign(.serif)
                        .bold()
                }                
            }
        }
    }
    
    @ViewBuilder
    func sidebar() -> some View {
        VStack(alignment: .leading) {
            Spacer()
            Grid {
                GridRow {
                    ForEach(upperGridItems) { item in
                        HStack {
                            Spacer()
                            ProfileGridView(model: item, destination: destination(_:))
                            Spacer()
                        }
                    }
                }
                
                ForEach(lowerGridItems) { item in
                    GridRow {
                        HStack {
                            Spacer()
                            ProfileGridView(model: item, destination: destination(_:))                            
                            Spacer()
                        }
                        .gridCellColumns(2)
                        
                    }

                }
            }
            Spacer()
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: ProfileGridItem.self, destination: destination(_:))
    }
    
    @ViewBuilder
    func destination(_ item: ProfileGridItem? = nil) -> some View {
        let workingItem = item ?? selectedItem
        innerDestination(workingItem)
            .ignoresSafeArea(.container, edges: [.bottom, .leading, .trailing])
            .navigationSplitViewColumnWidth(min: 250, ideal: 600)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { 
                    Text(workingItem.externalUrlString(for: addressModel.addressName))
                        .bold()
                        .font(.title2)
                        .fontDesign(.monospaced)
                }                    
            }
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
    
    var upperGridItems: [ProfileGridItemModel] {
        let items: [ProfileGridItemModel?] = [
            profileModel.loaded ? ProfileGridItemModel(item: .profile, isLoaded: true) : nil,
            nowModel.loaded ? ProfileGridItemModel(item: .now, isLoaded: true) : nil
        ]
        return items.compactMap({ $0 })
    }
    
    var lowerGridItems: [ProfileGridItemModel] {
        let items: [ProfileGridItemModel?] = [
            statusModel.loaded ? ProfileGridItemModel(item: .statuslog, isLoaded: true) : nil,
            purlModel.loaded ? ProfileGridItemModel(item: .purl, isLoaded: true) : nil,
            pastebinModel.loaded ? ProfileGridItemModel(item: .pastebin, isLoaded: true) : nil
        ]
        return items.compactMap({ $0 })
    }
}
