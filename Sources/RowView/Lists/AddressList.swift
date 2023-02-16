import SwiftUI

@available(iOS 16.1, *)
struct AddressListView: View {
    
    @EnvironmentObject
    var directory: DirectoryModel
    
    let model: ListModel<AddressModel>
    
    @Binding
    var selected: AddressModel?
    @Binding
    var sort: Sort
    
    @State
    var queryString: String = ""
    
    @EnvironmentObject
    var sceneModel: SceneModel
    
    init(model: ListModel<AddressModel>, selected: Binding<AddressModel?>, sort: Binding<Sort>) {
        self.model = model
        self._selected = selected
        self._sort = sort
    }
    
    var body: some View {
        BlockList(
            model: model,
            modelBuilder: { directory.addresses },
            rowBuilder: { _ in nil as ListItem<AddressModel>? },
            selected: $selected,
            context: .column,
            sort: $sort
        )
    }
}
