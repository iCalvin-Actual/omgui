//
//  File.swift
//  
//
//  Created by Calvin Chestnut on 3/8/23.
//

import Foundation

extension Array<FilterOption> {
    func applyFilters<T: Filterable>(to inputModels: [T], appModel: AppModel) -> [T] {
        inputModels
            .filter({ $0.include(with: self, appModel: appModel) })
    }
}
