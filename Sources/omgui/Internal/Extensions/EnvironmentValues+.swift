//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI


extension EnvironmentValues {
    var viewContext: ViewContext {
        get { self[ViewContextKey.self] }
        set { self[ViewContextKey.self] = newValue }
    }
    var fetcher: FetchConstructor {
        get { self[FetchConstructorKey.self] }
        set { self[FetchConstructorKey.self] = newValue }
    }
}

enum ViewContext {
    case column
    case detail
    case profile
}
struct ViewContextKey: EnvironmentKey {
    static var defaultValue: ViewContext {
        .column
    }
}
struct FetchConstructorKey: @preconcurrency EnvironmentKey {
    @MainActor
    static var defaultValue: FetchConstructor {
        try! .init(client: .sample, interface: SampleData(), lists: .init(), database: .inMemoryDatabase())
    }
}
