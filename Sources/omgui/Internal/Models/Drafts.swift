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
public protocol NamedDraftable: SomeDraftable, Equatable {
    associatedtype NamedDraftItem: NamedDraft
    
    var asDraft: Draft? { get }
}
public protocol MDDraftable: SomeDraftable {
    associatedtype MDDraftItem: MDDraft
}

public protocol DraftItem: Sendable, Identifiable {
    static var contentPlaceholder: String { get }
    
    var address: AddressName { get }
    var publishable: Bool { get }
    
    var content: String { get set }
    
    mutating
    func clear()
}
extension DraftItem {
    public var id: String {
        address
    }
    var publishable: Bool {
        !content.isEmpty
    }
    
    mutating
    public func clear() {
        content = ""
    }
}
public protocol MDDraft: DraftItem { }
public protocol NamedDraft: DraftItem {
    var name: String { get set }
    var listed: Bool { get set }
    
    init(address: AddressName, name: String, content: String, listed: Bool)
}
extension NamedDraft {
    public var id: String {
        address + name
    }
    
    mutating
    public func clear() {
        content = ""
        name = ""
        listed = false
    }
}

extension StatusResponse: MDDraftable {
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
        
        init(model: StatusResponse, id: String? = nil) {
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

extension PasteResponse: NamedDraftable {
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
        
        public init(address: AddressName, name: String, content: String, listed: Bool = true) {
            self.address = address
            self.name = name
            self.content = content
            self.listed = listed
        }
    }
    
    public var asDraft: Draft? {
        .init(address: addressName, name: name, content: content ?? "", listed: listed)
    }
}

extension PURLResponse: NamedDraftable {
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
        
        public init(_ model: PURLResponse, name: String? = nil) {
            self.init(
                address: model.owner,
                name: name ?? "",
                content: model.destination ?? "",
                listed: model.listed
            )
        }
        
        public init(address: AddressName, name: String, content: String = "", listed: Bool = true) {
            self.address = address
            self.name = name
            self.content = content
            self.listed = listed
        }
    }
    
    public var asDraft: Draft? {
        .init(address: owner, name: self.value, content: destination ?? "", listed: listed)
    }
}

extension PURLRowView {
    struct Preview: View {
        @SceneStorage("app.lol.address")
        var actingAddress: AddressName = ""
        
        @Environment(\.viewContext)
        var context: ViewContext
        
        let draftPoster: PURLDraftPoster
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .bottom) {
                    if context != .profile {
                        AddressNameView(draftPoster.address, font: .title3)
                    }
                    Spacer()
                    postButton
                }
                .padding(2)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("/\(draftPoster.namedDraft.name)")
                            .font(.title2)
                            .bold()
                            .fontDesign(.serif)
                            .lineLimit(2)
                        Spacer()
                    }
                    
                    if !draftPoster.namedDraft.content.isEmpty {
                        Text(draftPoster.namedDraft.content)
                            .font(.subheadline)
                            .fontDesign(.monospaced)
                            .lineLimit(5)
                    }
                }
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity)
                .padding(12)
                .foregroundColor(.black)
                .background(Color.lolRandom(draftPoster.draft.name))
                .cornerRadius(12, antialiased: true)
                .padding(.vertical, 4)
            }
            .frame(maxWidth: .infinity)
        }
        
        @ViewBuilder
        var postButton: some View {
            Button(action: {
                guard draftPoster.draft.publishable else {
                    return
                }
                Task {
                    await draftPoster.perform()
                    draftPoster.draft.clear()
                }
            }) {
                Label {
                    if draftPoster.result?.id == nil {
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
