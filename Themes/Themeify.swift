import SwiftUI

struct ThemeifyView: ViewModifier {
    let theme: Theme
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(theme.textColor)
            .accentColor(theme.linkColor)
            .background {
                switch theme.background {
                case .color(let color):
                    color
                case .gradient(_, colors: let colors):
                    LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
                }
            }
            .background(ignoresSafeAreaEdges: .all)
    }
}

extension View {
    func applyTheme(_ theme: Theme) -> some View {
        self
            .modifier(ThemeifyView(theme: theme))
    }
}

struct MyModifier_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Button("Hello Button", action: { })
                .applyTheme(.default)
            Button("Hello Button", action: { })
                .applyTheme(.cherryBlossom)
            Button("Hello Button", action: { })
                .applyTheme(.dark)
            Button("Hello Button", action: { })
                .applyTheme(.dracula)
        }
    }
}

