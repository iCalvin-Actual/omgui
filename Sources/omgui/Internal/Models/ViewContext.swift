//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import SwiftUI

public enum ViewContext {
    case column
    case detail
    case profile
}

struct ViewContextKey: EnvironmentKey {
    static var defaultValue: ViewContext {
        .column
    }
}

extension EnvironmentValues {
    var viewContext: ViewContext {
    get { self[ViewContextKey.self] }
    set { self[ViewContextKey.self] = newValue }
  }
}

struct NavigationPath: EnvironmentKey {
    static var defaultValue: NavigationPath {
        .init()
    }
}

extension EnvironmentValues {
    var navigationStack: NavigationPath {
    get { self[NavigationPath.self] }
    set { self[NavigationPath.self] = newValue }
  }
}
