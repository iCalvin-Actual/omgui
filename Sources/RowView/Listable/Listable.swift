//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 2/10/23.
//

import SwiftUI
import Foundation

@available(iOS 16.1, *)
protocol ContextProviding {
    associatedtype M: View
    func contextMenu(with appModel: AppModel) -> M
}

@available(iOS 16.1, *)
protocol Listable: Filterable, Sortable, Hashable, Identifiable, ContextProviding {
    var listTitle: String    { get }
    var listSubtitle: String { get }
    var listCaption: String? { get }
    var displayDate: Date?   { get }
}

@available(iOS 16.1, *)
extension Listable {
    var displayDate: Date? { nil }
    
    var listCaption: String? {
        guard let date = displayDate else {
            return nil
        }
        return DateFormatter.monthYear.string(from: date)
    }
}

@available(iOS 16.1, *)
extension AddressModel: Listable    {
    var listTitle: String { addressName.addressDisplayString }
    var listSubtitle: String { url?.absoluteString ?? "" }
    var displayDate: Date? { registered }
}
@available(iOS 16.1, *)
extension StatusModel: Listable     { 
    var listTitle: String     { status }
    var listSubtitle: String  { address.addressDisplayString }
    var displayDate: Date?    { posted }
}
@available(iOS 16.1, *)
extension PasteModel: Listable     { 
    var listTitle: String     { name }
    var listSubtitle: String  { String(content?.prefix(42) ?? "") }
    var listCaption: String?  { owner.addressDisplayString }
}
@available(iOS 16.1, *)
extension PURLModel: Listable     { 
    var listTitle: String     { value }
    var listSubtitle: String  { destination ?? "" }
    var listCaption: String?  { owner.addressDisplayString }
}
@available(iOS 16.1, *)
extension NowListing: Listable     { 
    var listTitle: String     { owner.addressDisplayString }
    var listSubtitle: String  { url.replacingOccurrences(of: "https://", with: "") }
    var displayDate: Date?    { updated }
}

//@available(iOS 16.1, *)
//protocol ContextMenuProviding {
//    associatedtype T: View
//    func contextMenu(with appModel: AppModel) -> T
//}

@available(iOS 16.1, *)
struct ContextMenuBuilder<T: Listable> {
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
