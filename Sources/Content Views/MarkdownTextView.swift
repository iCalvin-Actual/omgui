import SwiftUI

struct MarkdownTextView: View {
    let markdownText: String
    
    init(_ text: String) {
        self.markdownText = text
    }
    
    var body: some View {
        guard let attributed = try? AttributedString(styledMarkdown: markdownText) else {
            return Text(markdownText) 
        }
        return Text(attributed)
    }
}

