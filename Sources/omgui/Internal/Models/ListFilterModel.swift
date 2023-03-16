//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import Foundation

extension Array<FilterOption> {
    func applyFilters<T: Filterable>(to inputModels: [T], sceneModel: SceneModel) -> [T] {
        inputModels
            .filter({ $0.include(with: self, sceneModel: sceneModel) })
    }
}
