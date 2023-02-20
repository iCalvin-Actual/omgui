import SwiftUI

@available(iOS 16.1, *)
struct AddressListView: View {
    
    let model: ListModel<AddressModel>
    
    @ObservedObject
    var fetcher: AddressDirectoryDataFetcher
    
    @Binding
    var selected: AddressModel?
    @Binding
    var sort: Sort
    
    @State
    var queryString: String = ""
    
    @EnvironmentObject
    var sceneModel: SceneModel
    
    var body: some View {
        BlockList(
            model: model,
            modelBuilder: { fetcher.directory },
            rowBuilder: { _ in nil as ListItem<AddressModel>? },
            selected: $selected,
            context: .column,
            sort: $sort
        )
    }
}
