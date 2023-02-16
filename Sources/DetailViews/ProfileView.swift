import SwiftUI

@available(iOS 16.1, *)
struct ProfileView: View {
    @EnvironmentObject
    var sceneModel: SceneModel
    
    @ObservedObject
    var model: AddressDetailModels
    
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
                Text(model.addressModel.addressName.addressDisplayString)
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
                Text(model.addressModel.addressName.addressDisplayString)
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
                Text(model.addressModel.url?.absoluteString ?? "")
                
                Spacer()
            }
            
            Grid {
                ForEach(model.gridItems) { item in
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
            HTMLStringView(htmlContent: model.profileHTML)
        case .now:
            MarkdownTextView(model.nowString)
        case .statuslog:
            StatusList(
                model: .init(
                    sort: sort
                ),
                fetcher: .community,
                selected: $sceneModel.selectedStatus,
                sort: $sort,
                context: .profile
            )
        case .pastebin:
            PasteList(
                model: .init(
                    sort: sort
                ),
                fetcher: .init(
                    addresses: [model.addressModel]),
                selected: $sceneModel.selectedPaste,
                sort: $sort,
                context: .profile
            )
        case .purl:
            PURLList(
                model: .init(
                    sort: sort
                ),
                fetcher: .init(
                    addresses: [model.addressModel]),
                selected: $sceneModel.selectedPURL,
                sort: $sort,
                context: .profile
            )
        }
    }
}
