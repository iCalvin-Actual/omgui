//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import Foundation

extension Array<FilterOption> {
    @MainActor
    func applyFilters<T: Filterable>(to inputModels: [T], in scene: SceneModel) -> [T] {
        inputModels
            .filter({ $0.include(with: self, in: scene) })
    }
}
