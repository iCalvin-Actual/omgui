//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 4/2/23.
//

import Foundation

protocol DraftItem {
    var content: String { get set }
}

protocol MDDraft: DraftItem {
}
protocol NamedDraft: DraftItem {
    var name: String { get set }
    var content: String { get set }
    var listed: Bool { get set }
    
    init(name: String, content: String, listed: Bool)
}

public extension StatusModel {
    struct Draft: MDDraft {
        public var id: String?
        public var content: String
        public var emoji: String?
        public var externalUrl: String?
    }
}

public extension NowModel {
    struct Draft: MDDraft {
        public var content: String
        public var listed: Bool
        
        public init(content: String, listed: Bool) {
            self.content = content
            self.listed = listed
        }
    }
}

public extension AddressProfile {
    struct Draft: MDDraft {
        public var content: String
        public var publish: Bool
    }
}

public extension PasteModel {
    struct Draft: NamedDraft {
        public var name: String
        public var content: String
        public var listed: Bool
        
        init(name: String, content: String = "", listed: Bool = false) {
            self.name = name
            self.content = content
            self.listed = listed
        }
    }
}

public extension PURLModel {
    struct Draft: NamedDraft {
        public var name: String
        public var content: String
        public var listed: Bool
        
        init(name: String, content: String = "", listed: Bool = false) {
            self.name = name
            self.content = content
            self.listed = listed
        }
    }
}
