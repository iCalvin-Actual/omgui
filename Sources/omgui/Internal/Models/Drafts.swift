//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 4/2/23.
//

import Foundation


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
    var content: String { get set }
}
public protocol MDDraft: DraftItem {
}
public protocol NamedDraft: DraftItem {
    var name: String { get set }
    var listed: Bool { get set }
    
    init(name: String, content: String, listed: Bool)
}

extension StatusModel: MDDraftable {
    public typealias MDDraftItem = Draft
    
    public struct Draft: MDDraft {
        public var id: String?
        public var content: String
        public var emoji: String?
        public var externalUrl: String?
    }
}

extension NowModel: MDDraftable {
    public typealias MDDraftItem = Draft
    
    public struct Draft: MDDraft {
        public var content: String
        public var listed: Bool
        
        public init(content: String, listed: Bool) {
            self.content = content
            self.listed = listed
        }
    }
}

extension AddressProfile: MDDraftable {
    public typealias MDDraftItem = Draft
    
    public struct Draft: MDDraft {
        public var content: String
        public var publish: Bool
    }
}

extension PasteModel: NamedDraftable {
    public typealias NamedDraftItem = Draft
    
    public struct Draft: NamedDraft {
        public var name: String
        public var content: String
        public var listed: Bool
        
        public init(name: String, content: String = "", listed: Bool = false) {
            self.name = name
            self.content = content
            self.listed = listed
        }
    }
}

extension PURLModel: NamedDraftable {
    public typealias NamedDraftItem = Draft
    public struct Draft: NamedDraft {
        public var name: String
        public var content: String
        public var listed: Bool
        
        public init(name: String, content: String = "", listed: Bool = false) {
            self.name = name
            self.content = content
            self.listed = listed
        }
    }
}
