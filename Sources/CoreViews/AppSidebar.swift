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
                Section {
                    ForEach(model.content(in: group)) { item in 
                        NavigationLink(value: item) {
                            if let icon = item.iconName {
                                HStack {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .fontDesign(.serif)
                                        .bold()
                                    Text(item.displayString)
                                        .font(.title2)
                                        .fontDesign(.serif)
                                    Spacer()
                                }
                            } else {
                                Text(item.displayString)
                            }
                        }
//                        .foregroundColor(.black)
                        .padding(16)
                        .background(Color.lolRandom(item))
                        .cornerRadius(12)
                        .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                        .listRowSeparator(.hidden, edges: .all)
                    }
                } header: {
                    Text(group.displayName)
                        .fontDesign(.monospaced)
                        .font(.subheadline)
                        .bold()
                }
            }
            .listStyle(.plain)

            Spacer()
            
            if let accountView = accountViewBuilder() {
                accountView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("app.lol")
                    .font(.title)
                    .bold()
                    .fontDesign(Font.Design.serif)
                    .foregroundColor(.accentColor)
            }
        })
    }
}
