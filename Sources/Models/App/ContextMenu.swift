import SwiftUI


@available(iOS 16.1, *)
protocol ContextProviding {
    associatedtype M: View
    func contextMenu(with appModel: AppModel) -> M
}

@available(iOS 16.1, *)
struct ContextMenuBuilder<T: ContextProviding> {
    @Binding
    var selected: T?
    
    @ViewBuilder
    func contextMenu(for item: T, with appModel: AppModel) -> some View {
        Group {
            Button(action: {
                self.selected = item
            }, label: {
                Label("Select", systemImage: "binoculars") })
            Divider()
            item.contextMenu(with: appModel)
        }
    }
}

@available(macCatalyst 16.1, *)
extension Listable { 
    func contextMenu(with appModel: AppModel) -> some View {
        EmptyView()
    }
}

@available(iOS 16.1, *)
extension AddressModel: ContextProviding {
    @ViewBuilder
    func contextMenu(with appModel: AppModel) -> some View {
        Group {
            Button(action: { }, label: { Label("Another One", systemImage: "pin") })
        }
    }
}
