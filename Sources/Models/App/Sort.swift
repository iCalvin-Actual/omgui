import SwiftUI

enum Sort: String {
    case alphabet
    case dateAscending
    case dateDescending
    case shuffle
}

protocol Sortable {
    var primarySortValue: String { get }
}

protocol DateSortable: Sortable {
    var dateValue: Date? { get }
}

extension Sort {
    func sorted<S: Sortable>(_ lhs: S, _ rhs: S) -> Bool {
        switch self {
        case .alphabet:
            return lhs.primarySortValue < rhs.primarySortValue
        case .dateAscending:
            guard let lhD = (lhs as? DateSortable)?.dateValue, let rhD = (rhs as? DateSortable)?.dateValue else {
                return false
            }
            return lhD > rhD
        case .dateDescending:
            guard let lhD = (lhs as? DateSortable)?.dateValue, let rhD = (rhs as? DateSortable)?.dateValue else {
                return false
            }
            return lhD < rhD
        case .shuffle:
            return true
        }
    }
}

extension Array where Element: Sortable {
    func sorted(with sort: Sort) -> [Element] {
        self.sorted(by: sort.sorted(_:_:))
    }
}

struct SortOrderMenu: View {
    @EnvironmentObject
    var sceneModel: SceneModel
    
    @Binding
    var sort: Sort
    
    var body: some View {
        Menu {
            Button {
                withAnimation {
                    sort = .alphabet
                }
            } label: {
                if sort == .shuffle {
                    Label("Alphabetical", systemImage: "checkmark")
                } else {
                    Text("Alphabetical")
                }
            }
            Button {
                withAnimation {
                    sort = .dateAscending
                }
            } label: {
                if sort == .shuffle {
                    Label("Recent First", systemImage: "checkmark")
                } else {
                    Text("Recent First")
                }
            }
            Button {
                withAnimation {
                    sort = .dateDescending
                }
            } label: {
                if sort == .shuffle {
                    Label("Oldest First", systemImage: "checkmark")
                } else {
                    Text("Oldest First")
                }
            }
            Button {
                withAnimation {
                    sort = .shuffle
                }
            } label: {
                if sort == .shuffle {
                    Label("Shuffle", systemImage: "checkmark")
                } else {
                    Text("Shuffle")
                }
            }
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down.square")
        }
    }
}

extension AddressModel: DateSortable {
    var primarySortValue: String { name }
    var dateValue: Date? { registered }
}

extension StatusModel: DateSortable {
    var primarySortValue: String { address }
    var dateValue: Date? { posted }
}

extension PasteModel: Sortable {
    var primarySortValue: String { name }
}

extension PURLModel: Sortable {
    var primarySortValue: String { value }
}

extension NowListing: DateSortable {
    var primarySortValue: String { owner }
    var dateValue: Date? { updated }
}

