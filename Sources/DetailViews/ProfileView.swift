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
    var selectedItem: ProfileGridItem = .statuslog
    
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
                    .navigationSplitViewStyle(.balanced)
                default:
                    sidebar()                    
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text(addressModel.addressName.addressDisplayString)
                    .font(.title)
                    .fontDesign(.serif)
                    .foregroundColor(.accentColor)
                    .bold()
            }
        }
    }
    
    @ViewBuilder
    func sidebar() -> some View {
        VStack(alignment: .leading) {
            Grid {
                Section {
                    GridRow {
                        ForEach(pageGridItems) { item in
                            HStack {
                                Spacer()
                                ProfileGridView(model: item, destination: destination(_:))
                                Spacer()
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("pages")
                            .fontDesign(.monospaced)
                            .font(.subheadline)
                            .bold()
                            .padding(8)
                        Spacer()
                    }
                }
                
                Section {
                    ForEach(moreGridItems) { item in
                        GridRow {
                            HStack {
                                Spacer()
                                ProfileGridView(model: item, destination: destination(_:))
                                Spacer()
                            }
                            .gridCellColumns(2)
                        }
                        
                    }
                } header: {
                    HStack {
                        Text("more")
                            .fontDesign(.monospaced)
                            .font(.subheadline)
                            .bold()
                            .padding(8)
                        Spacer()
                    }
                }
            }
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .principal, content: {
                Text("")                
            })
        }
        .navigationTitle(self.addressModel.addressName.addressDisplayString)
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
    }
    
    @ViewBuilder
    func innerDestination(_ item: ProfileGridItem) -> some View {
        switch item {
        case .profile:
            HTMLStringView(htmlContent: profileModel.html ?? "")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Text(ProfileGridItem.profile.externalUrlString(for: addressModel.addressName))
                            .bold()
                            .font(.callout)
                            .foregroundColor(.accentColor)
                            .fontDesign(.monospaced)
                    }
                }
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text(ProfileGridItem.statuslog.externalUrlString(for: addressModel.addressName))
                        .bold()
                        .font(.callout)
                        .foregroundColor(.accentColor)
                        .fontDesign(.monospaced)
                }
            }
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text(ProfileGridItem.pastebin.externalUrlString(for: addressModel.addressName))
                        .bold()
                        .font(.callout)
                        .foregroundColor(.accentColor)
                        .fontDesign(.monospaced)
                }
            }
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text(ProfileGridItem.purl.externalUrlString(for: addressModel.addressName))
                        .bold()
                        .font(.callout)
                        .foregroundColor(.accentColor)
                        .fontDesign(.monospaced)
                }
            }
        }
    }
    
    var pageGridItems: [ProfileGridItemModel] {
        let items: [ProfileGridItemModel?] = [
            ProfileGridItemModel(item: .profile, isLoaded: true),
            ProfileGridItemModel(item: .now, isLoaded: true)
        ]
        return items.compactMap({ $0 })
    }
    
    var moreGridItems: [ProfileGridItemModel] {
        let items: [ProfileGridItemModel?] = [
            ProfileGridItemModel(item: .statuslog, isLoaded: true),
            ProfileGridItemModel(item: .purl, isLoaded: true),
            ProfileGridItemModel(item: .pastebin, isLoaded: true)
        ]
        return items.compactMap({ $0 })
    }
}
