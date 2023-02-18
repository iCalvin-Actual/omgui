import SwiftUI

@available(iOS 16.1, *)
struct ProfileView: View {
    @EnvironmentObject
    var sceneModel: SceneModel
    @EnvironmentObject
    var appModel: AppModel
    
    @ObservedObject
    var model: AddressDetailsDataFetcher
    
    @State
    var sort: Sort = .alphabet
    
    @State
    var selectedStatus: StatusModel?
    @State
    var selectedPaste: PasteModel?
    @State
    var selectedPURL: PURLModel?
    
    let context: Context
    
    @State
    var sidebarVisibility: NavigationSplitViewVisibility = .all
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Text(model.addressName.addressDisplayString)
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
    
    var brokenBody: some View {
        VStack {
            HStack(alignment: .bottom) {
                Text(model.addressName.addressDisplayString)
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
                Text(model.url?.absoluteString ?? "")
                
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
            HTMLStringView(htmlContent: model.profileFetcher?.html ?? "")
        case .now:
            NowContentView(model: model.nowFetcher)
        case .statuslog:
            StatusList(
                model: .init(
                    sort: sort
                ),
                fetcher: appModel.fetchConstructor.statusLog(for: [model.addressName]),
                selected: $sceneModel.selectedStatus,
                sort: $sort,
                context: .profile
            )
        case .pastebin:
            if let pasteFetcher = model.pasteFetcher {
                PasteList(
                    model: .init(
                        sort: sort
                    ),
                    fetcher: pasteFetcher,
                    selected: $sceneModel.selectedPaste,
                    sort: $sort,
                    context: .profile
                )
            }
        case .purl:
            if let purlFetcher = model.purlFetcher {
                PURLList(
                    model: .init(
                        sort: sort
                    ),
                    fetcher: purlFetcher,
                    selected: $sceneModel.selectedPURL,
                    sort: $sort,
                    context: .profile
                )
            }
        }
    }
    
    var gridItems: [ProfileGridItemModel] {
        [
            .init(
                item: .profile,
                isLoaded: model.profileFetcher != nil
            ),
            .init(
                item: .now,
                isLoaded: model.nowFetcher != nil
            ),
            .init(
                item: .statuslog,
                isLoaded: true
            ),
            .init(
                item: .purl,
                isLoaded: model.purlFetcher != nil
            ),
            .init(
                item: .pastebin,
                isLoaded: model.pasteFetcher != nil
            )
        ]
    }
}
