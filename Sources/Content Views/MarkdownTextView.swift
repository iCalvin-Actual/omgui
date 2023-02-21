import SwiftUI

struct MarkdownTextView: View {
    let markdownText: String
    
    init(_ text: String) {
        self.markdownText = text
    }
    
    var body: some View {
        ScrollView {
            if let attributed = try? AttributedString(styledMarkdown: markdownText) {
                Text(attributed)
            } else {
                Text(markdownText)
            }
        }
    }
}

