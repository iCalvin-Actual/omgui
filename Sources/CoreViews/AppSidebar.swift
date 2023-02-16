import SwiftUI

@available(iOS 16.1, *)
struct AppSidebar: View {
    @State 
    var model: SidebarViewModel
    
    @EnvironmentObject
    var sceneModel: SceneModel
    
    @Binding
    var selected: NavigationColumn?
    
    var accountViewBuilder: (() -> AccountBar?)
    
    var body: some View {
        VStack {
            List(model.groups, selection: $selected) { group in  
                Section(group.displayName) {
                    ForEach(model.content(in: group)) { item in 
                        NavigationLink(value: item) {
                            if let icon = item.iconName {
                                Label(item.displayString, systemImage: icon)   
                            } else {
                                Text(item.displayString)
                            }
                        }
                    }
                }
            }
            .listRowSeparator(.hidden, edges: .all)

            Spacer()
            
            if let accountView = accountViewBuilder() {
                accountView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
