//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 2/10/23.
//

import Foundation

protocol Listable: Filterable, Sortable, Hashable, Identifiable {
    var listTitle: String    { get }
    var listSubtitle: String { get }
    var listCaption: String? { get }
    var displayDate: Date?   { get }
}

extension Listable {
    var displayDate: Date? { nil }
    
    var listCaption: String? {
        guard let date = displayDate else {
            return nil
        }
        return DateFormatter.short.string(from: date)
    }
}

extension AddressModel: Listable    {
    var listTitle: String { addressName }
    var listSubtitle: String { url?.absoluteString ?? "" }
    var displayDate: Date? { registered }
}
extension StatusModel: Listable     { 
    var listTitle: String     { status }
    var listSubtitle: String  { address.addressDisplayString }
    var displayDate: Date?    { posted }
}
extension PasteModel: Listable     { 
    var listTitle: String     { name }
    var listSubtitle: String  { String(content?.prefix(42) ?? "") }
    var listCaption: String?  { owner.addressDisplayString }
}
extension PURLModel: Listable     { 
    var listTitle: String     { value }
    var listSubtitle: String  { destination ?? "" }
    var listCaption: String?  { owner.addressDisplayString }
}
extension NowModel: Listable     { 
    var listTitle: String     { owner.addressDisplayString }
    var listSubtitle: String  { url }
    var displayDate: Date?    { updated }
}
