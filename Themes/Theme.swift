import SwiftUI

enum Theme: String {
    case `default`
    case cherryBlossom
    case dark
    case dracula
    
    var id: String {
        switch self {
        case .default:
            return "default"
        case .cherryBlossom:
            return "cherry-blossom"
        case .dark:
            return "dark"
        case .dracula:
            return "dracula"
        default:
            return ""
        }
    }
    var name: String { 
        switch self {
        case .default:
            return "Default"
        case .cherryBlossom:
            return "Cherry Blossom"
        case .dark:
            return "Dark"
        case .dracula:
            return "Dracula"
        default:
            return ""
        }
    }
    var author: String { 
        switch self {
        case .default:
            return "omg.lol"
        case .cherryBlossom:
            return "omg.lol"
        case .dark:
            return "omg.lol"
        case .dracula:
            return "Bye"
        default:
            return ""
        }
    }
    var background: BackgroundStyle { 
        switch self {
        case .default:
            return .gradient(degrees: 0, colors: [
                .init(hex: "3fb6b6"),
                .init(hex: "d56b86")
            ])
        case .cherryBlossom:
            return .color(.init(hex: "ffb7c5"))
        case .dark:
            return .color(.init(hex: "222222"))
        case .dracula:
            return .color(.init(hex: "44475a"))
        default:
            return .color(.init(.systemBackground))
        }
    }
    var textColor: Color { 
        switch self {
        case .default:
            return .init(hex: "000000")
        case .cherryBlossom:
            return .init(hex: "000000")
        case .dark:
            return .init(hex: "cccccc")
        case .dracula:
            return .init(hex: "f8f8f2")
        default:
            return .primary
        }
    }
    var linkColor: Color { 
        switch self {
        case .default:
            return .init(hex: "000000")
        case .cherryBlossom:
            return .init(hex: "333333")
        case .dark:
            return .init(hex: "cccccc")
        case .dracula:
            return .init(hex: "f8f8f2")
        default:
            return .accentColor
        }
    }
    var iconColor: Color { 
        switch self {
        case .default:
            return .init(hex: "009990")
        case .cherryBlossom:
            return .init(hex: "b53c54")
        case .dark:
            return .init(hex: "cccccc")
        case .dracula:
            return .init(hex: "f8f8f2")
        default:
            return .accentColor
        }
    }    
}

extension Theme {
    var backgroundStyle: any ShapeStyle {
        switch background {
        case .color(let color):
            return color
        case .gradient(_, colors: let colors):
            return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
        }
    }
}

enum BackgroundStyle {
    case gradient(degrees: Float, colors: [Color])
    case color(Color)
}

