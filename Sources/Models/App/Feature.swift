import SwiftUI

@available(iOS 16.1, *)
extension UIDotAppDotLOL {
    enum Feature: String {
        case service
        case status
        case now
        case paste
        case purl
        case weblog
        
        var displayName: String {
            switch self {
            case .service:
                return "omg.lol"
            case .status:
                return "StatusLog"
            case .now:
                return "Now Page"
            case .paste:
                return "PasteBin"
            case .purl:
                return "PURLs"
            case .weblog:
                return "Weblog"
            }
        }
    }
}
