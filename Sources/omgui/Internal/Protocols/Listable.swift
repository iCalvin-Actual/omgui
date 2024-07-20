//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/5/23.
//

import Foundation

protocol Listable: Filterable, Sortable, Menuable, Hashable, Identifiable {
    var listTitle: String    { get }
    var listSubtitle: String { get }
    var listCaption: String? { get }
    var displayDate: Date?   { get }
    var iconURL: URL?        { get }
}

extension Listable {
    var hideIcon: Bool {
        iconURL == nil && addressName.isEmpty
    }
}

extension Listable {
    var displayDate: Date? { nil }
    var iconURL: URL? { nil }
    
    var listCaption: String? {
        guard let date = displayDate else {
            return nil
        }
        return DateFormatter.shortDate.string(from: date)
    }
}

extension AddressModel: Listable {
    var listTitle: String { addressName.addressDisplayString }
    var listSubtitle: String { url?.absoluteString ?? "" }
    var displayDate: Date? { registered }
}
extension StatusResponse: Listable     {
    var listTitle: String     { status }
    var listSubtitle: String  { address.addressDisplayString }
    var displayDate: Date?    { posted }
    var listCaption: String?  { DateFormatter.short.string(from: posted) }
}
extension PasteResponse: Listable     {
    var listTitle: String     { name }
    var listSubtitle: String  { String(content?.prefix(42) ?? "") }
    var listCaption: String?  { owner.addressDisplayString }
}
extension PURLResponse: Listable     {
    var listTitle: String     { value }
    var listSubtitle: String  { destination ?? "" }
    var listCaption: String?  { owner.addressDisplayString }
}
extension NowListing: Listable     {
    var listTitle: String     { owner.addressDisplayString }
    var listSubtitle: String  { url.replacingOccurrences(of: "https://", with: "") }
    var displayDate: Date?    { updated }
    var hideIcon: Bool { false }
}
