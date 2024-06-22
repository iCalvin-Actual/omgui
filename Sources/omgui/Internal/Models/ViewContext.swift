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
