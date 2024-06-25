//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 4/2/23.
//

import MarkdownUI
import SwiftUI


public protocol SomeDraftable: Sendable {
    associatedtype Draft: DraftItem
}
public protocol NamedDraftable: SomeDraftable {
    associatedtype NamedDraftItem: NamedDraft
}
public protocol MDDraftable: SomeDraftable {
    associatedtype MDDraftItem: MDDraft
}

public protocol DraftItem: Sendable {
    static var contentPlaceholder: String { get }
    
    var address: AddressName { get }
    var publishable: Bool { get }
    
    var content: String { get set }
    
    mutating
    func clear()
}
extension DraftItem {
    var publishable: Bool {
        !content.isEmpty
    }
    
    mutating
    public func clear() {
        content = ""
    }
}
public protocol MDDraft: DraftItem {
}
public protocol NamedDraft: DraftItem {
    var name: String { get set }
    var listed: Bool { get set }
    
    init(address: AddressName, name: String, content: String, listed: Bool)
}
extension NamedDraft {
    mutating
    public func clear() {
        content = ""
        name = ""
        listed = false
    }
}

extension StatusModel: MDDraftable {
    public typealias MDDraftItem = Draft
    
    public struct Draft: MDDraft {
        static public var contentPlaceholder: String {
            "what's new?"
        }
        
        public var address: AddressName
        
        public var id: String?
        public var content: String
        public var emoji: String
        public var externalUrl: String?
        
        public var publishable: Bool {
            guard id == nil else {
                return true
            }
            return !content.isEmpty
        }
        
        public var displayEmoji: String {
            emoji.isEmpty ? "💗" : emoji
        }
        
        mutating
        public func clear() {
            id = nil
            content = ""
            emoji = ""
            externalUrl = ""
        }
        
        init(model: StatusModel, id: String? = nil) {
            self.address = model.address
            self.id = id
            self.content = model.status
            self.emoji = model.emoji ?? ""
        }
        
        init(address: AddressName, id: String? = nil, content: String, emoji: String, externalUrl: String? = nil) {
            self.address = address
            self.id = id
            self.content = content
            self.emoji = emoji
            self.externalUrl = externalUrl
        }
    }
}

extension NowModel: MDDraftable {
    public typealias MDDraftItem = Draft
    
    public struct Draft: MDDraft {
        static public var contentPlaceholder: String {
            "what's the latest?"
        }
        
        public var address: AddressName
        
        public var content: String
        public var listed: Bool
        
        public var publishable: Bool { true }
    }
}

extension AddressProfile: MDDraftable {
    public typealias MDDraftItem = Draft
    
    public struct Draft: MDDraft {
        static public var contentPlaceholder: String {
            "from the top"
        }
        
        public var address: AddressName
        
        public var content: String
        public var publish: Bool
        
        public var publishable: Bool { true }
    }
}

extension PasteModel: NamedDraftable {
    public typealias NamedDraftItem = Draft
    
    public struct Draft: NamedDraft {
        static public var contentPlaceholder: String {
            "what do you have?"
        }
        
        public var address: AddressName
        
        public var name: String
        public var content: String
        public var listed: Bool
        
        public var publishable: Bool {
            !name.isEmpty && !content.isEmpty
        }
        
        public init(address: AddressName, name: String, content: String, listed: Bool) {
            self.address = address
            self.name = name
            self.content = content
            self.listed = listed
        }
    }
}

extension PURLModel: NamedDraftable {
    public typealias NamedDraftItem = Draft
    public struct Draft: NamedDraft {
        static public var contentPlaceholder: String {
            "where are we going?"
        }
        
        public var address: AddressName
        
        public var name: String
        public var content: String
        public var listed: Bool
        
        public var publishable: Bool {
            !name.isEmpty && !content.isEmpty
        }
        
        public init(address: AddressName, name: String, content: String = "", listed: Bool = false) {
            self.address = address
            self.name = name
            self.content = content
            self.listed = listed
        }
    }
}

extension StatusRowView {
    struct Preview: View {
        @SceneStorage("app.lol.address")
        var actingAddress: AddressName = ""
        
        @Environment(\.viewContext)
        var context: ViewContext
        
        let draftPoster: StatusDraftPoster
        
        var address: AddressName {
            if draftPoster.draft.address == .autoUpdatingAddress {
                return actingAddress
            }
            return draftPoster.draft.address
        }
        
        var body: some View {
            VStack(alignment: .trailing, spacing: 0) {
                HStack {
                    AddressIconView(address: address)
                    
                    Text(draftPoster.draft.displayEmoji)
                        .font(.system(size: 42))
                    
                    Spacer()
                    postButton
                }
                /*
                 This was tricky to set up
                 so I'm leaving it here
                 
    //                    Text(model.displayEmoji)
    //                        .font(.system(size: 44))
    //                    + Text(" ").font(.largeTitle) +
                 */
                rowBody
                    .padding(.bottom, 2)
                    .asCard(backgroundColor: .lolRandom(draftPoster.draft.displayEmoji), radius: 6)
            }
            .lineLimit(3)
            .multilineTextAlignment(.leading)
        }
        
        @ViewBuilder
        var rowBody: some View {
            appropriateMarkdown
                .font(.system(.body))
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .environment(\.colorScheme, .light)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        @ViewBuilder
        var appropriateMarkdown: some View {
            if draftPoster.draft.content.isEmpty {
                Text("")
                    .padding(.vertical, 4)
            } else {
                Markdown(draftPoster.draft.content)
                    .foregroundColor(.black)
            }
        }
        
        @ViewBuilder
        var postButton: some View {
            Button(action: {
                guard draftPoster.draft.publishable else {
                    return
                }
                if draftPoster.draft.id?.isEmpty ?? true {
                    draftPoster.address = actingAddress
                }
                Task {
                    await draftPoster.perform()
                    draftPoster.draft.clear()
                }
            }) {
                Label {
                    if draftPoster.draft.id == nil {
                        Text("publish")
                    } else {
                        Text("update")
                    }
                } icon: {
                    Image(systemName: "arrow.up.circle.fill")
                }
                .font(.headline)
            }
            .disabled(!draftPoster.draft.publishable)
        }
    }
}
